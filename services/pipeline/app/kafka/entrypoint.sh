#!/usr/bin/env bash
set -euo pipefail

log_entry() {
  local level="$1" module="$2" message="$3"
  jq -cn \
    --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg level "$level" \
    --arg module "$module" \
    --arg message "$message" \
    '{ts: $ts, level: $level, module: $module, msg: $message}'
}

info() {
  log_entry "info" "kafka-init" "$@"
}

CONFIG_FILE="$CONFIGDIR_TARGET/values/tmdb.yaml"
BOOTSTRAP_SERVERS=${KAFKA_BROKERS}

# Topic settings
NUM_PARTITIONS=${KAFKA_NUM_PARTITIONS}
MAX_MESSAGE_BYTES=${KAFKA_MAX_MESSAGE_BYTES}
CLEANUP_POLICY=${KAFKA_CLEANUP_POLICY}
COMPRESSION_TYPE=${KAFKA_COMPRESSION_TYPE}

# Segment settings
SMALL_SEGMENT_BYTES=16777216  # 16MB for small topics (export, embeddings, etc.)
LARGE_SEGMENT_BYTES=536870912 # 512MB for large topics (detail, normalized, etc.)

# Extract topics from config
TOPICS=($(yq e '.resources[].topic[]' "$CONFIG_FILE"))

if [[ -z "${TOPICS[*]:-}" ]]; then
  info "No topics found in $CONFIG_FILE"
  exit 1
fi

info "Fetching topic cache from Redpanda..."
# Cache the topic details locally to avoid redundant network/API calls.
# We default to an empty JSON array '[]' in case there are no topics yet.
TOPIC_CACHE=$(rpk topic list --brokers "$BOOTSTRAP_SERVERS" --format json 2> /dev/null || echo "[]")

# Function to manage a single topic
manage_topic() {
  local topic_name="$1"
  local segment_bytes
  local topic_info
  local current_partitions
  local add_partitions

  # Determine segment size
  if [[ "$topic_name" == tmdb.detail.* ]] || [[ "$topic_name" == tmdb.normalized.* ]]; then
    segment_bytes=$LARGE_SEGMENT_BYTES
  else
    segment_bytes=$SMALL_SEGMENT_BYTES
  fi

  # Query our local cache to see if the topic exists and get its details
  topic_info=$(echo "$TOPIC_CACHE" | jq -c -r --arg t "$topic_name" '.[] | select(.name == $t)')

  if [[ -z "$topic_info" ]]; then
    info "Creating topic: $topic_name"
    rpk topic create "$topic_name" \
      --brokers "$BOOTSTRAP_SERVERS" \
      --replicas 1 \
      --partitions "$NUM_PARTITIONS" \
      -c cleanup.policy="$CLEANUP_POLICY" \
      -c max.message.bytes="$MAX_MESSAGE_BYTES" \
      -c compression.type="$COMPRESSION_TYPE" \
      -c segment.bytes="$segment_bytes" > /dev/null
  else
    info "Updating config for topic: $topic_name"
    rpk topic alter-config "$topic_name" \
      --brokers "$BOOTSTRAP_SERVERS" \
      -s cleanup.policy="$CLEANUP_POLICY" \
      -s max.message.bytes="$MAX_MESSAGE_BYTES" \
      -s compression.type="$COMPRESSION_TYPE" \
      -s segment.bytes="$segment_bytes" > /dev/null

    # Extract current partition count from the cached JSON info
    current_partitions=$(echo "$topic_info" | jq -r '.partitions')

    if [ "$current_partitions" -lt "$NUM_PARTITIONS" ]; then
      add_partitions=$((NUM_PARTITIONS - current_partitions))
      info "Expanding $topic_name from $current_partitions to $NUM_PARTITIONS partitions (+$add_partitions)"
      rpk topic add-partitions "$topic_name" \
        --brokers "$BOOTSTRAP_SERVERS" \
        --num "$add_partitions" > /dev/null
    elif [ "$current_partitions" -gt "$NUM_PARTITIONS" ]; then
      info "Can not reduce partition count for $topic_name from $current_partitions to $NUM_PARTITIONS partitions." >&2
    else
      info "No changes required for $topic_name"
    fi
  fi
}

# Main execution loop
for TOPIC in "${TOPICS[@]}"; do
  manage_topic "$TOPIC"
done

info "Topic provisioning completed successfully."
