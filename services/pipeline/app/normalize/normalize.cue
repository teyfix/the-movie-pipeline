@experiment(try)

package normalize

import "pipelines.lokal/shared/tmdb"

export: {for prop, resource in tmdb.resources if resource.normalize != _|_ {
	"normalize/\(prop)": {
		input: {
			label: prop
			redpanda: {
				seed_brokers: ["${KAFKA_BROKERS}"]
				topics: [resource.topic.detail]
				consumer_group:            resource.consumer.normalize
				start_from_oldest:         true
				fetch_max_bytes:           resource.normalize.kafka.batch_size
				fetch_max_partition_bytes: resource.normalize.kafka.batch_size
				fetch_max_wait:            resource.normalize.kafka.max_wait
				max_yield_batch_bytes:     resource.normalize.kafka.batch_size
				partition_buffer_bytes:    resource.normalize.kafka.buffer_size
			}
			processors: [{
				mapping: """
					meta output_id = this.data.id
					meta output_topic = "\(resource.topic.normalized)"
					"""
			}]
		}

		pipeline: {
			processors: [
				{
					label:   "unwrap"
					mapping: #"from "normalize/mapping/unwrap.blobl""#
				},
				{
					label:   "sanitize"
					mapping: #"from "normalize/mapping/sanitize.blobl""#
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
				batching: {
					count:  100
					period: "1s"
				}
			}
		}
	}
}
}
