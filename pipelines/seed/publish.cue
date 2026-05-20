package seed

import "pipelines.lokal/shared/tmdb"

export: "seed/publish.yaml": {
	sources: {
		for name, resource in tmdb.resources if resource.download != _|_ {
			"tmdb_file_\(name)": {
				type: "file"
				include: [for prefix in resource.download.prefix {
					"${TMDB_DOWNLOAD_DIR:?}/\(prefix)_ids_*.json.gz"
				}]
				ignore_checkpoints: true
			}
		}
	}
	transforms: {
		for name, resource in tmdb.resources if resource.download != _|_ {
			"tmdb_envelope_\(name)": {
				type: "remap"
				inputs: ["tmdb_file_\(name)"]
				source: """
					  parsed = parse_json!(.message)
					  del(.message)
					  . = {
					    "data": parsed,
					    "vector": .,
					    "meta": {
					      "v": 1,
					      "ts": now(),
					      "topic": "\(resource.topic.export)",
					    }
					  }
					"""
			}
		}
	}
	sinks: {
		tmdb_publish_redpanda: {
			type: "redpanda"
			inputs: ["tmdb_envelope_*"]
			bootstrap_servers: "${KAFKA_BROKERS:?}"
			topic:             "{{ meta.topic }}"
			key_field:         "data.id"
			encoding: {
				codec: "json"
			}
			acknowledgements: {
				enabled: true
			}
			compression: "zstd"
		}
	}
}
