package enrich

import "pipelines.lokal/shared/tmdb"

resources: {
	input: {
		broker: {
			inputs: [for resource in tmdb.resources {
				label: resource.kind
				redpanda: {
					seed_brokers: ["${KAFKA_BROKERS}"]
					topics: [resource.topic.export]
					consumer_group:         resource.consumer.enrich
					start_from_oldest:      true
					partition_buffer_bytes: "100kb"
					max_yield_batch_bytes:  "100kb"
				}
				processors: [
					if resource.enrich.min_popularity > 0 {
						switch: [{
							check: #"json("data.popularity").number(0) < \#(resource.enrich.min_popularity)"#
							processors: [
								{
									metric: {
										type: "counter"
										name: "enrich_low_popularity"
										labels:
											kind: resource.kind
									}
								},
								{mapping: "root = deleted()"},
							]
						}]
					},
					{
						label:   "\(resource.kind)_enrich"
						mapping: """
              meta output_topic = "\(resource.topic.detail)"
              meta output_id = this.data.id
              meta kind = "\(resource.kind)"
              meta endpoint = "\(resource.enrich.endpoint)"
                .format(this.data.id)
              meta passthrough = \(resource.enrich.passthrough)
              """
					},
				]
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
		label: "kafka"
		redpanda: {
			seed_brokers: ["${KAFKA_BROKERS}"]
			topic:             #"${! meta("output_topic") }"#
			key:               #"${! meta("output_id") }"#
			max_message_bytes: "100MB"
			compression:       "zstd"
		}
	}

}
