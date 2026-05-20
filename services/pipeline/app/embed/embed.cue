@experiment(try)

package embed

import "pipelines.lokal/shared/tmdb"

export: "embed/resources": {
	input: {
		broker: {
			inputs: [for prop, resource in tmdb.resources if resource.embed != _|_ {
				label: prop
				redpanda: {
					seed_brokers: ["${KAFKA_BROKERS}"]
					topics: [resource.topic.normalized]
					consumer_group:            resource.consumer.embed
					start_from_oldest:         true
					fetch_max_bytes:           resource.embed.kafka.batch_size
					fetch_max_partition_bytes: resource.embed.kafka.batch_size
					fetch_max_wait:            resource.embed.kafka.max_wait
					max_yield_batch_bytes:     resource.embed.kafka.batch_size
					partition_buffer_bytes:    resource.embed.kafka.buffer_size
				}
				processors: [
					if resource.embed.transform != _|_ {
						if resource.embed.transform.mapping == true {
							label:   "map_\(prop)"
							mapping: #"from "embed/mapping/\#(prop).blobl""#
						} else {
							label:   "map_\(prop)"
							mapping: #"from "embed/mapping/\#(resource.embed.transform.mapping)""#
						}
						if resource.embed.transform.unarchive {
							unarchive: {
								format: "json_array"
							}
						}
					},
					{
						label:   "meta_\(prop)"
						mapping: """
            meta output_topic = "\(resource.topic.embed)"
            meta output_id = this.data.id.or(this.source.data.id)
            meta kind = "\(prop)"
            """
					},
				]
			}]
		}
	}

	pipeline: {
		processors: [
			{
				branch: {
					request_map: """
						root = {
							"inputs": [this.data.overview]
						}
						"""
					processors: [
						{
							label: "http_tei_api"
							http: {
								url:  "${TEI_API_URL}/embed"
								verb: "POST"
								headers:
									"Content-Type": "application/json"
								retries: 3
								successful_on: [200]
								drop_on: [404]
								extract_headers:
									include_prefixes: ["X-Cache-Status"]
							}
						},
						{
							switch: [{
								check: #"!["HIT", "STALE", "REVALIDATED", "UPDATING"].contains(meta("X-Cache-Status").or("MISS").uppercase())"#
								processors: [{
									rate_limit: {
										resource: "tei"
									}
								}]
							}]
						},
					]
					result_map: """
						root.data.embedding = this.index(0)
						"""
				}
			},
			{
				catch: [
					{resource: "error_mapping"},
				]
			},
		]
	}

	output: {
		label: "redpanda"
		redpanda: {
			seed_brokers: ["${KAFKA_BROKERS}"]
			topic:             #"${! meta("output_topic") }"#
			key:               #"${! meta("output_id") }"#
			max_message_bytes: "100MB"
			compression:       "zstd"
		}
	}
}
