@experiment(try)

package enrich

import "list"

import "pipelines.lokal/shared/tmdb"

export: "enrich/resources": {
	input: {
		broker: {
			inputs: [for prop, resource in tmdb.resources if resource.enrich != _|_ {
				label: prop
				redpanda: {
					seed_brokers: ["${KAFKA_BROKERS}"]
					topics: [resource.topic.export]
					consumer_group:            resource.consumer.enrich
					start_from_oldest:         true
					fetch_max_bytes:           resource.enrich.kafka.batch_size
					fetch_max_partition_bytes: resource.enrich.kafka.batch_size
					fetch_max_wait:            resource.enrich.kafka.max_wait
					max_yield_batch_bytes:     resource.enrich.kafka.batch_size
					partition_buffer_bytes:    resource.enrich.kafka.buffer_size
				}
				processors: list.FlattenN([
					if resource.enrich.filter.min_popularity > 0 {
						label: "filter_popularity_\(prop)"
						switch: [{
							check: #"json("data.popularity").number(0) < \#(resource.enrich.filter.min_popularity)"#
							processors: [
								{
									metric: {
										type: "counter"
										name: "enrich_low_popularity"
										labels:
											kind: prop
									}
								},
								{mapping: "root = deleted()"},
							]
						}]
					},
					if resource.enrich.transform != _|_ {[
						if resource.enrich.transform.mapping == true {
							mapping: #"from "enrich/mapping/resource/\#(prop).blobl""#
						} else {
							mapping: #"from "enrich/mapping/resource/\#(resource.enrich.transform.mapping)""#
						},
						if resource.enrich.transform.unarchive {
							unarchive: {
								format: "json_array"
							}
						},
					]},
					{
						label:   "meta_\(prop)"
						mapping: """
              meta output_topic = "\(resource.topic.detail)"
              meta output_id = this.data.id
              meta kind = "\(prop)"
              meta endpoint = "\(resource.enrich.api.endpoint)"
              meta passthrough = \(resource.enrich.api.passthrough)
              """
					},
					{
						label:   "map_endpoint_\(prop)"
						mapping: #"from "enrich/mapping/endpoint.blobl""#
					},
				], 1)
			}]
		}
	}

	pipeline: {
		processors: [
			{
				switch: [
					{
						check: "@passthrough.or(false)"
						processors: [
							{
								metric: {
									type: "counter"
									name: "enrich_passthrough"
									labels:
										kind: "@kind"
								}
							},
							{
								mapping: """
									root = {
										"data": this.data,
										"meta": {
											"v": 1,
											"ts": now(),
										},
										"source": this,
										"connect": @,
									}
									"""
							},
						]
					},
					{
						processors: [
							{
								branch: {
									request_map: """
                    root = ""
                    """
									processors: [
										{
											label: "http_tmdb_api"
											http: {
												url:  #"${TMDB_API_URL}${! meta("endpoint") }"#
												verb: "GET"
												headers:
													Authorization: "Bearer ${TMDB_API_SECRET}"
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
														resource: "tmdb"
													}
												}]
											}]
										},
									]
									result_map: """
                    root = {
                      "data": this,
                      "meta": {
                        "v": 1,
                        "ts": now(),
                      },
                      "source": root,
                      "connect": @,
                    }
                    """
								}
							},
						]
					},
				]
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
