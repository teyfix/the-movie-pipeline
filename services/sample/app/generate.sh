#!/usr/bin/env bash
set -euo pipefail

# Generate sanitized sample JSON files for all normalized TMDB resources.
# Samples are extracted from Kafka topics and processed to replace empty strings with null.
snake_to_pascal() {
  local IFS=_
  local words=($1)
  # Capitalize first letter of every element in the array
  echo "${words[@]^}" | tr -d ' '
}

btime() {
  /usr/bin/time "$@"
}

kafka_url="${KAFKA_BROKERS:?}"
sample_dir="/sample"
sample_count="${NUM_SAMPLE:?}"
jaq_enabled="${ENABLE_JAQ:-false}"
resource_kinds=(
  # Small resources
  "collection"
  "keyword"
  "production-company"
  "tv-network"

  # Large resources
  "movie"
  "person"
  "season"
  "show"
)

jaq_filter=$(
  cat << 'EOF'
walk(
  if type == "string" and . == "" then null
  elif type == "array" then
    map(select(. != null)) | select(length > 0)
  elif type == "object" then with_entries(select(.value != null))
  else .
  end
)
EOF
)

echo "Checking Kafka connection..."
kcat -b "$kafka_url" -L -m 3 > /dev/null

for kind_name in "${resource_kinds[@]}"; do
  echo
  echo "=== Processing $kind_name ==="

  topic_name="tmdb.normalized.$kind_name"
  pascal_name="$(snake_to_pascal "$kind_name")"

  tmp_download="$(mktemp).ndjson"
  tmp_sanitized="$(mktemp).ndjson"

  output_merged="$sample_dir/$kind_name.json"
  output_types="$sample_dir/$kind_name.d.ts"

  echo "Downloading $sample_count samples into $tmp_download"
  btime -f 'Downloaded samples in %es' kcat \
    -b "$kafka_url" \
    -C -e -q \
    -c "$sample_count" \
    -m 3 \
    -o beginning \
    -t "$topic_name" \
    -X fetch.max.bytes=52428800 \
    -X fetch.message.max.bytes=10485760 \
    -X fetch.min.bytes=1048576 \
    -X fetch.wait.max.ms=100 > "$tmp_download"

  if [[ "$jaq_enabled" == "true" ]]; then
    echo
    echo "Sanitizing samples into $tmp_sanitized"
    btime -f 'Sanitized samples in %es' parallel -a "$tmp_download" --pipepart --block 10M \
      "jaq -c '$jaq_filter'" > "$tmp_sanitized"
  else
    tmp_sanitized="$tmp_download"
  fi

  echo
  echo "Serializing samples into $output_merged"

  echo "[" > "$output_merged"
  head -n 1 "$tmp_sanitized" >> "$output_merged"
  btime -f 'Serialized samples in %es' tail -n +2 "$tmp_sanitized" \
    | parallel --pipe --block 10M "sed 's/^/,/'" >> "$output_merged"
  echo "]" >> "$output_merged"

  echo
  echo "Generating types into $output_types"
  btime -f 'Generated types in %es' bun x quicktype --src "$output_merged" -o "$output_types" -t "$pascal_name" \
    --lang ts \
    --no-explicit-unions \
    --prefer-unions \
    --prefer-types \
    --just-types \
    --prefer-const-values

  echo
  echo "Formatting generated types in place"
  btime -f 'Formatted types in %es' bun x prettier --log-level=silent --write --single-quote --print-width 80 "$output_types"

  echo
  echo "Removing artifacts: $tmp_download, $tmp_sanitized"
  rm -f "$tmp_download" "$tmp_sanitized"
done

echo
echo "All samples generated successfully in $sample_dir/"
