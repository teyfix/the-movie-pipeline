package tmdb

import units "pipelines.lokal/shared/units"

nsp: "tmdb"

#Resource: {
	kind: string
	topic: {
		export:     string | *"\(nsp).export.\(kind)"
		detail:     string | *"\(nsp).detail.\(kind)"
		normalized: string | *"\(nsp).normalized.\(kind)"
		embed:      string | *"\(nsp).embed.\(kind)"
	}
	consumer: {
		enrich:    string | *"\(nsp).enrich.\(kind).v1"
		normalize: string | *"\(nsp).normalize.\(kind).v1"
		embed:     string | *"\(nsp).embed.\(kind).v1"
		ingest:    string | *"\(nsp).ingest.\(kind).v1"
	}
	download?: {
		prefix: [...string]
	}
	enrich?: {
		// Drop messages below this popularity score before enrichment
		filter: {
			min_popularity: number | *0
		}

		// TMDB API fetch behaviour
		api: {
			// Endpoint path to fetch detail data (e.g. "/3/movie/{{ data.id }}?append_to_response=alternative_titles,...")
			endpoint: string
			// Skip the API call and pass the source message through as-is
			passthrough: bool | *false
		}

		// Bloblang transform applied after fetch
		transform?: {
			// true  → load from "mapping/resource/<name>.blobl"
			// string → load from the given path
			mapping: true | string
			// Unarchive the mapping output as a JSON array
			unarchive: bool | *true
		}

		// Kafka consumer tuning
		kafka: {
			max_wait:    units.#Duration | *"5s"
			batch_size:  units.#Size | *"100kb"
			buffer_size: units.#Size | *"200kb"
		}
	}
	normalize?: {
		kafka: {
			max_wait:    units.#Duration | *"5s"
			batch_size:  units.#Size | *"5mb"
			buffer_size: units.#Size | *batch_size
		}
	}
	embed?: {
		// Bloblang transform applied after fetch
		transform: {
			// true  → load from "mapping/resource/<name>.blobl"
			// string → load from the given path
			mapping: string | *true
			// Unarchive the mapping output as a JSON array
			unarchive: bool | *false
		}

		// Kafka consumer tuning
		kafka: {
			max_wait:    units.#Duration | *"5s"
			batch_size:  units.#Size | *"5mb"
			buffer_size: units.#Size | *batch_size
		}
	}
	ingest?: {
		streams: [Name=string]: {
			mapping: {
				from?:       string
				unarchive:   bool | *true
				deduplicate: bool | *true
				drop_error:  bool | *false
			}
			output: {
				table: string
				primary: [...string]
				columns: [...string]
				updated_at: bool | *false
			}
		}
		// Kafka consumer tuning
		kafka: {
			max_wait:    units.#Duration | *"5s"
			batch_size:  units.#Size | *"5mb"
			buffer_size: units.#Size | *batch_size
		}
	}
}

resources: [Name=string]: #Resource
export: "values/tmdb": {
	"resources": resources
}
