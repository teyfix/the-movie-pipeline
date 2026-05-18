@experiment(try)

package enrich

import "pipelines.lokal/shared/tmdb"

normalize: {
	input: {
		broker: {
			inputs: [for prop, resource in tmdb.resources {
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
			}]
		}
	}

	pipeline: {
		processors: [
			{
				label:   "unwrap"
				mapping: #"from "mapping/unwrap.blobl""#
			},
			{
				label:   "sanitize"
				mapping: #"from "mapping/sanitize.blobl""#
			},
			{
				catch: [
					{resource: "error_mapping"},
				]
			},
		]
	}

	output: {
		label: "kafka"
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
