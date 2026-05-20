@experiment(try)

package ingest

import "list"

import "strings"

import "strconv"

import "pipelines.lokal/shared/tmdb"

export: {for prop, resource in tmdb.resources if resource.ingest != _|_ {
	"ingest/\(prop)": {
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
					let $primary = stream.output.primary
					let $columns = stream.output.columns

					let $uniq = {
						for col in list.Concat([$primary, $columns]) {
							"\(col)": col
						}
					}

					let $setUpdate = list.FlattenN([
						$columns,
						if stream.output.updated_at == true {"updated_ts"},
					], 1)

					label: "\(name)"
					processors: list.FlattenN([
						if stream.mapping.from == _|_ {
							label:   "mapping_\(name)"
							mapping: #"from "ingest/mapping/\#(prop)/\#(name).blobl""#
						} else {
							label:   "mapping_\(name)"
							mapping: #"from "ingest/mapping/\#(stream.mapping.from)""#
						},
						if stream.mapping.unarchive {
							label: "unarchive_\(name)"
							unarchive: {
								format: "json_array"
							}
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
								group_by_value: {
									value: strings.Join([for col in $primary {"${! json(\(strconv.Quote(col))) }"}], ":")
								}
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
					sql_insert: {
						driver: "pgx"
						dsn:    "${POSTGRES_URL}"
						table:  #""${PG_SCHEMA}"."\#(stream.output.table)""#
						columns: [for col in $uniq {"\(strconv.Quote(col))"}]
						args_mapping: strings.Join(
							list.FlattenN([
								"root = [",
								for v, col in $uniq {"  this.\(col),"},
								"]",
							], 1),
							"\n",
							)

						suffix: strings.Join(
							[
								"ON CONFLICT (",
								strings.Join([for col in $primary {
									"  \(strconv.Quote(col))"
								}], ",\n"),
								")",
								"DO UPDATE SET",
								strings.Join([for col in $setUpdate {
									"  \(strconv.Quote(col)) = EXCLUDED.\(strconv.Quote(col))"
								}], ",\n"),
							],
							"\n",
							)
						max_in_flight:      "${INGEST_MAX_IN_FLIGHT}"
						conn_max_open:      "${INGEST_CONN_MAX_OPEN}"
						conn_max_idle:      "${INGEST_CONN_MAX_IDLE}"
						conn_max_life_time: "${INGEST_CONN_MAX_LIFE_TIME}"
					}
				},
			]
			}
		}
	}
}
}
