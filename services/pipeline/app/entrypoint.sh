#!/usr/bin/env bash
set -euo pipefail

APP_CONFIG="/app"
APP_STAGE="/tmp/$USERNAME"
APP_TARGET="/home/$USERNAME"

export max_concurrency=8

# prints the relative path to the current directory
rel() {
  input="$1"
  echo "${input#"$(pwd)/"}"
}

export -f rel

render_single() {
  input="$1"                   # service/template.yaml.gotpl
  output="${input%.*}"         # service/template.yaml
  name="$(basename "$output")" # template.yaml
  name="${name%.*}"            # template

  TEMPLATE_NAME="$name" \
    gomplate --config /values/.gomplate.yaml -f "$input" -o "$output"

  echo "Rendered: $(rel "$input") -> $(rel "$output")"
  rm -f "$input"
}

export -f render_single

render_shared() {
  input="$1"                   # service/.shared.yaml.gotpl
  outdir="$(dirname "$input")" # service
  name="$(basename "$input")"  # .shared.yaml.gotpl
  name="${name%.*}"            # .shared.yaml

  find "$outdir" -type f -name "$name" \
    | xargs -I% -P$max_concurrency bash -c 'set -euo pipefail; render_shared_single "$1" "$2"' _ "$input" %
  rm -f "$input"
}

export -f render_shared

render_shared_single() {
  input="$1"                         # service/.shared.yaml.gotpl
  values="$2"                        # service/domain/.shared.yaml
  ext="$(basename "$input")"         # .shared.yaml.gotpl
  ext="${ext%.*}"                    # .shared.yaml
  ext="${ext##*.}"                   # yaml
  output="$(dirname "$values").$ext" # service/domain.yaml
  name="$(basename "$output")"       # domain.yaml
  name="${name%.*}"                  # domain

  TEMPLATE_NAME="$name" \
    gomplate --config /values/.gomplate.yaml -d values="file:///$values" -f "$input" -o "$output"

  echo "Rendered: $(rel "$input") -> $(rel "$output") @ $(rel "$values")"
  rm -f "$values"
}

export -f render_shared_single

log_entry() {
  local level="$1" module="$2" message="$3"
  jq -cnM \
    --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg level "$level" \
    --arg module "$module" \
    --arg message "$message" \
    '{ts: $ts, level: $level, module: $module, msg: $message}'
}

info() {
  log_entry "info" "entrypoint" "$@"
}

log_stream() {
  local module="$1" level="${2:-info}"
  while IFS= read -r line; do
    log_entry "$level" "$module" "$line"
  done
}

render() {
  # Copy and render config files
  rsync -av --delete "$APP_CONFIG/" "$APP_STAGE/" \
    | log_stream rsync:stage info

  # Render config files
  find "$APP_STAGE" -type f -name '*.gotpl' ! -name '.*' \
    | xargs -I% -P$max_concurrency bash -c 'set -euo pipefail; render_single "$1"' _ % \
    | log_stream render:single info

  # Render shared config files
  find "$APP_STAGE" -type f -name '.*.gotpl' \
    | xargs -I% -P$max_concurrency bash -c 'set -euo pipefail; render_shared "$1"' _ % \
    | log_stream render:shared info

  # Synchronize config files to destination
  rsync -av --delete "$APP_STAGE/" "$APP_TARGET/" \
    | log_stream rsync:target info
}

watch() {
  # Added -q to suppress noisy setup messages on every loop,
  # and 2>&1 to ensure all output is captured by log_stream.
  while inotifywait -q -r -e modify,create,delete /values "$APP_CONFIG" 2>&1 | log_stream "inotify" "info"; do
    info "Config change detected, re-rendering..."
    render
  done
}

datadir() {
  # Prepare directories
  mkdir -p "/data"

  # Update ownership
  chown -R "$USERNAME:$USERNAME" "/data"
}

render
datadir
watch &

# Run as user
if [ -f "$EXEC_CMD" ]; then
  info "Running: $EXEC_CMD"
  exec su "$USERNAME" -s /bin/bash -- -c "/bin/bash '$EXEC_CMD'"
else
  info "Executing: $EXEC_CMD"
  exec su "$USERNAME" -s /bin/bash -- -c "shopt -s globstar; $EXEC_CMD"
fi
