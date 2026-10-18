#!/usr/bin/env python3
"""Exercise the production TEI/collector wiring without a model or GPU."""

import concurrent.futures
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import threading
import time
from urllib.error import HTTPError
from urllib.parse import urlencode
from urllib.request import Request, urlopen


class Origin(BaseHTTPRequestHandler):
  sequence = 0
  lock = threading.Lock()
  failing = False

  def do_GET(self):
    if self.path == "/fail":
      type(self).failing = True
    if self.path == "/recover":
      type(self).failing = False
    self.respond()

  def do_POST(self):
    self.respond()

  def respond(self):
    with self.lock:
      type(self).sequence += 1
      sequence = self.sequence
    body = self.rfile.read(int(self.headers.get("Content-Length", 0))).decode()
    if body == "concurrent":
      time.sleep(0.2)
    status = 503 if self.path == "/embed" and type(self).failing else 200
    data = json.dumps({"sequence": sequence, "body": body, "path": self.path}).encode()
    self.send_response(status)
    self.send_header("Content-Type", "application/json")
    self.send_header("Content-Length", str(len(data)))
    if body == "no-store":
      self.send_header("Cache-Control", "no-store")
    self.end_headers()
    self.wfile.write(data)

  def log_message(self, *_args):
    pass


def request(url, body=None, headers=None):
  data = None if body is None else body.encode()
  try:
    response = urlopen(Request(url, data=data, headers=headers or {}), timeout=10)
  except HTTPError as error:
    response = error
  with response:
    return response.status, dict(response.headers.items()), response.read().decode()


def eventually(check, timeout=60):
  deadline = time.monotonic() + timeout
  while time.monotonic() < deadline:
    if result := check():
      return result
    time.sleep(1)
  raise AssertionError(f"Condition did not succeed: {check}")


def main():
  root = Path(__file__).resolve().parents[1]
  os.chdir(root)
  os.environ["PWD"] = str(root)
  parent = root / ".state/observability-tests"
  parent.mkdir(parents=True, exist_ok=True)
  work = Path(tempfile.mkdtemp(prefix="run-", dir=parent))
  project = "tmdb-observability-" + work.name.removeprefix("run-").replace("_", "x")
  origin = project + "-origin"
  source = work / "collector"
  shutil.copytree(root / "services/metrics/vector", source)
  for directory in ["tei-logs", "tei-cache", "tmdb-logs/api-logs", "tmdb-cache/api", "tmdb-cache/files", "postgres-logs", "pipeline-logs/normalize", "vector-data", "vector-logs"]:
    (work / directory).mkdir(parents=True)
  # Loki's upstream user must be able to create its disposable storage.
  (work / "loki").mkdir(mode=0o777)
  (work / "loki").chmod(0o777)
  base = ["docker", "compose", "-p", project, "-f", "docker-compose.yaml"]
  configuration = json.loads(subprocess.check_output(base + ["config", "--format", "json"], text=True))
  routes = configuration["configs"]["tei-routes"]["content"]
  # Use a short freshness window to exercise native stale behavior.
  routes = routes.replace("ttl: 1d", "ttl: 2s").replace('"201": 1d, "204": 1d', '"201": 2s, "204": 2s')
  namespace = configuration["services"]["tei-server"]["environment"]["EMBEDDING_MODEL"]
  routes = routes.replace(namespace, "fixture-model-v1")

  def bind(relative, target, readonly=False):
    return {"type": "bind", "source": str(work / relative), "target": target, "read_only": readonly}

  override = {
    "configs": {"tei-routes": {"content": routes}},
    "services": {
      "tei": {"ports": ["127.0.0.1::8080"], "volumes": [bind("tei-logs", "/var/log/nginx"), bind("tei-cache", "/var/cache/nginx")]},
      "loki": {"ports": ["127.0.0.1::3100"], "volumes": [bind("loki", "/loki")]},
      "vector": {
        "ports": ["127.0.0.1::9598"],
        "volumes": [bind("collector", "/app", True), bind("vector-data", "/data"), bind("vector-logs", "/var/log/vector"), bind("tei-logs", "/mnt/log/tei", True), bind("tei-cache", "/mnt/cache/tei", True), bind("tmdb-logs", "/mnt/log/tmdb", True), bind("tmdb-cache", "/mnt/cache/tmdb", True), bind("postgres-logs", "/mnt/log/postgres", True), bind("pipeline-logs", "/mnt/log/pipeline", True)],
      },
    },
  }
  override_path = work / "compose.json"
  override_path.write_text(json.dumps(override))
  compose = base + ["-f", str(override_path)]

  def run(*args, **kwargs):
    return subprocess.run(args, check=True, **kwargs)

  def endpoint(service, port):
    address = subprocess.check_output(compose + ["port", service, str(port)], text=True).strip()
    return "http://" + address

  def engine(command):
    return subprocess.check_output(compose + ["exec", "-T", "vector", "sh", "-c", command], text=True).strip()

  try:
    run(*compose, "up", "-d", "--build", "--no-deps", "--wait", "--wait-timeout", "120", "tei", "loki")
    run("docker", "run", "-d", "--name", origin, "--network", project + "_net-tei", "--network-alias", "tei-server.lokal", "--cpus", "1", "--memory", "128m", "-v", str(Path(__file__).resolve()) + ":/check.py:ro", "python:3.14-alpine", "python", "/check.py", "--origin")
    tei = endpoint("tei", 8080)
    eventually(lambda: request(tei + "/health")[0] == 200)
    run(*compose, "up", "-d", "--no-deps", "--wait", "--wait-timeout", "120", "vector")
    metrics = endpoint("vector", 9598)
    loki = endpoint("loki", 3100)

    def post(body, headers=None):
      status, response_headers, data = request(tei + "/embed", body, {"Content-Type": "application/json", **(headers or {})})
      assert status == 200, (status, data)
      return response_headers.get("X-Cache-Status"), json.loads(data)

    first = post("one")
    assert first[0] == "MISS" and post("one") == ("HIT", first[1])
    assert post("two")[1] != first[1]
    large = "x" * 20000
    assert post(large)[0] == "MISS" and post(large)[0] == "HIT"
    for headers in [{"Authorization": "Bearer fixture"}, {"Cookie": "fixture=1"}, {"X-Cache-Bypass": "1"}]:
      assert post("one", headers)[0] == "BYPASS"
    assert post("no-store")[1] != post("no-store")[1]
    for path in ["/metrics", "/health"]:
      left, right = request(tei + path), request(tei + path)
      assert left[2] != right[2] and "X-Cache-Status" not in left[1]
    # A cache lock should send one concurrent fill to the origin.
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
      fills = list(pool.map(lambda _: post("concurrent"), range(4)))
    assert len({item[1]["sequence"] for item in fills}) == 1, fills
    stale = post("stale")
    time.sleep(3.2)
    request(tei + "/fail")
    assert post("stale") == ("STALE", stale[1])
    request(tei + "/recover")
    before_model = post("model-change")[1]
    override["configs"]["tei-routes"]["content"] = routes.replace("fixture-model-v1", "fixture-model-v2")
    override_path.write_text(json.dumps(override))
    run(*compose, "up", "-d", "--no-deps", "--force-recreate", "--wait", "tei")
    tei = endpoint("tei", 8080)
    assert post("model-change")[1] != before_model
    assert post("model-change")[0] == "HIT"
    print("PASS TEI POST/body/model identity, bypass, lock, stale, health and metrics", flush=True)

    (work / "pipeline-logs/normalize/engine.jsonl").write_text(json.dumps({"level": "INFO", "message": "pipeline-fixture"}) + "\n")
    (work / "postgres-logs/postgresql.json").write_text(json.dumps({"message": "postgres-fixture"}) + "\n")
    access = {"time": "2026-10-18T00:00:00Z", "status": 200, "bytes_sent": 10, "method": "GET", "uri": "/retry-fixture", "args": "", "rt": 0.6, "urt": "0.3, 0.6", "uct": "0.1, 0.4", "uht": "0.2, 0.5", "cache": "MISS", "proxy_host": "fixture"}
    (work / "tmdb-logs/api-logs/cache-proxy-access.jsonl").write_text(json.dumps(access) + "\n")

    def logs(selector):
      query = urlencode({"query": selector, "limit": 1000})
      status, _, body = request(loki + "/loki/api/v1/query_range?" + query)
      assert status == 200, body
      return [json.loads(value[1]) for stream in json.loads(body)["data"]["result"] for value in stream["values"]]

    for service, message in [("normalize", "pipeline-fixture"), ("postgres", "postgres-fixture")]:
      eventually(lambda: any(item["log"].get("message") == message for item in logs('{service="' + service + '"}')))
    eventually(lambda: logs('{service="tei"}'))
    retries = eventually(lambda: [item["log"] for item in logs('{service="tmdb"}') if item["log"].get("uri") == "/retry-fixture"])
    assert {(item["uct"], item["uht"], item["urt"]) for item in retries} == {(0.1, 0.2, 0.3), (0.4, 0.5, 0.6)}, retries
    eventually(lambda: "nginx_requests_total" in request(metrics + "/metrics")[2] and "storage_bytes_total" in request(metrics + "/metrics")[2])
    print("PASS file logs delivered to Loki; retry timings and cache storage metrics", flush=True)

    active = engine("readlink /run/teyfix-pipeline/active")
    pid = engine("cat /run/teyfix-pipeline/engine.pid")
    config = source / "config/vector.yaml"
    original = config.read_bytes()
    config.write_bytes(original + b"\ninvalid: [\n")
    eventually(lambda: engine("test -f /run/teyfix-pipeline/rejected && echo rejected || true"))
    assert engine("readlink /run/teyfix-pipeline/active") == active
    assert engine("cat /run/teyfix-pipeline/engine.pid") == pid
    assert request(metrics + "/metrics")[0] == 200
    config.write_bytes(original.replace(b"namespace: vector", b"namespace: vector_reload"))
    eventually(lambda: "vector_reload_" in request(metrics + "/metrics")[2])
    assert engine("cat /run/teyfix-pipeline/engine.pid") == pid
    assert engine("test ! -f /run/teyfix-pipeline/rejected && echo recovered") == "recovered"
    config.write_bytes(original)
    print("PASS collector invalid-edit retention and native reload", flush=True)
    (work / "result.json").write_text(json.dumps({"tei": "passed", "loki": "passed", "metrics": "passed", "reload": "passed"}) + "\n")
  finally:
    subprocess.run(compose + ["logs", "--no-color"], stdout=(work / "compose.log").open("w"), stderr=subprocess.STDOUT)
    subprocess.run(["docker", "rm", "-f", origin], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    run(*compose, "down", "--remove-orphans", "--volumes")
    print(f"Test artifacts: {work.relative_to(root)}", flush=True)


if __name__ == "__main__":
  if "--origin" in sys.argv:
    ThreadingHTTPServer(("0.0.0.0", 8080), Origin).serve_forever()
  else:
    main()
