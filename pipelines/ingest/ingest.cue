@experiment(try)

package ingest

import "list"

import "strings"

import "strconv"

import "pipelines.lokal/shared/tmdb"

export: {for prop, resource in tmdb.resources if resource.ingest != _|_ {
	"ingest/\(prop).yaml": {
		input: {
			label: "redpanda"
			redpanda: {
				seed_brokers: ["${KAFKA_BROKERS}"]
				topics: [resource.topic.normalized]
				consumer_group:            resource.consumer.ingest
				start_from_oldest:         true
				fetch_max_bytes:           resource.ingest.kafka.batch_size
				fetch_max_partition_bytes: resource.ingest.kafka.batch_size
				fetch_max_wait:            resource.ingest.kafka.max_wait
				max_yield_batch_bytes:     resource.ingest.kafka.batch_size
				partition_buffer_bytes:    resource.ingest.kafka.buffer_size
			}
			processors: [{
				label:   "kafka_meta_\(prop)"
				mapping: """
					meta tmdb_id = this.data.id
					meta tmdb_kind = "\(prop)"
					meta tmdb_version = this.meta.ts

					root = this.assign({
						"data": {
							"version_ts": this.meta.ts
						}
					})
					"""
			}]
		}

		output: {
			broker: {
				outputs: [for name, stream in resource.ingest.streams {
					let $colUniq = {
						for col in list.Concat([stream.output.primary, stream.output.columns]) {
							"\(col)": col // duplicate keys silently unify → dedup
						}
					}

					let $colConflict = [
						for col in stream.output.columns {col},
						if stream.output.updated_at == true {"updated_at"},
					]

					label: "\(name)"
					processors: list.FlattenN([
						if stream.mapping.from == _|_ {
							label:   "mapping_\(name)"
							mapping: #"from "mapping/\#(prop)/\#(name).blobl""#
						} else {
							label:   "mapping_\(name)"
							mapping: #"from "\#(stream.mapping.from)""#
						},
						if stream.mapping.drop_error {
							label: "drop_error_\(name)"
							switch: [{
								check: #"json("~error") != null"#
								processors: [
									{
										label: "drop_error_log_\(name)"
										log: {
											level: "WARN"
											message: """
												${! json("~error.message").or("dropping the message with ~error field") }
												"""
											fields_mapping: "root = this"
										}
									},
									{
										label:   "drop_error_deleted_\(name)"
										mapping: "root = deleted()"
									},
								]
							}]
						},
						if stream.mapping.deduplicate {[
							{
								label: "dedup_meta_\(name)"
								mapping: """
                  root = this.assign({
                    "version_ts": this.version_ts.or(@tmdb_version)
                  })
                  """
							},
							{
								label: "dedup_group_\(name)"
								group_by_value: strings.Join([for col in stream.output.primary {#"${! json("\#(col)") }"#}], "-")
							},
							{
								label: "dedup_archive_\(name)"
								archive:
									format: "json_array"
							},
							{
								label: "dedup_sort_\(name)"
								mapping: """
                  root = this.sort_by(e -> e.version_ts).index(-1)
                  """
							},
						]},
					], 1)
					sql_insert:
						driver: "pgx"
					dsn:   "${POSTGRES_URL}"
					table: #""${PG_SCHEMA}"."\#(stream.output.table)""#

					columns: [for _, col in $colUniq {#""\#(col)""#}]
					args_mapping: strings.Join(
						list.Concat([
							["root = ["],
							[for v, col in $colUniq {"  this.\(col),"}],
							["]"],
						]),
						"\n",
						)

					suffix: strings.Join(
						[
							"ON CONFLICT (",
							strings.Join([for col in stream.output.primary {
								"  \(strconv.Quote(col))"
							}], ",\n"),
							")",
							"DO UPDATE SET",
							strings.Join([for col in $colConflict {
								"  \(strconv.Quote(col)) = EXCLUDED.\(strconv.Quote(col))"
							}], ",\n"),
						],
						"\n",
						)
				},
			]
		}
		}
	}
}
}
