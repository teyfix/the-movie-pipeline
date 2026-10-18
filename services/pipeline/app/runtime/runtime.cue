package runtime

import (
	"strings"
	"pipelines.lokal/embed"
	"pipelines.lokal/enrich"
	"pipelines.lokal/ingest"
	"pipelines.lokal/normalize"
	"pipelines.lokal/seed"
	"pipelines.lokal/shared/connect"
	"pipelines.lokal/shared/vector"
)

service: ("seed" | "enrich" | "normalize" | "embed" | "ingest") @tag(service)

if service == "seed" {
	files: {
		for name, body in seed.export {
			"\(strings.Replace(name, "/", "-", -1)).yaml": body
		}
		"metrics.yaml": vector.export["vector/config"]
	}
}

if service != "seed" {
	_streams: {
		if service == "enrich" {enrich.export}
		if service == "normalize" {normalize.export}
		if service == "embed" {embed.export}
		if service == "ingest" {ingest.export}
	}
	files: {
		"root.yaml": connect.export["connect/observability"] & connect.export["connect/resources"]
		for name, body in _streams {
			"streams/\(strings.TrimPrefix(name, service+"/")).yaml": body
		}
	}
}
