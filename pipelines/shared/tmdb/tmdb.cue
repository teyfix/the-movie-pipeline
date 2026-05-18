package tmdb

import units "pipelines.lokal/shared/units"

#Resource: {
	kind: string
	topic: {
		embed?:     string
		detail:     string
		normalized: string
		export:     string
	}
	consumer: {
		enrich:    string
		normalize: string
		embed?:    string
		ingest:    string
	}
	download?: {
		prefix: [...string]
	}
	enrich: {
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
			unarchive: bool | *false
		}

		// Kafka consumer tuning
		kafka: {
			max_wait:    units.#Duration | *"5s"
			batch_size:  units.#Size | *"100kb"
			buffer_size: units.#Size | *"200kb"
		}
	}
	normalize: {
		kafka: {
			max_wait:    units.#Duration | *"5s"
			batch_size:  units.#Size | *"5mb"
			buffer_size: units.#Size | *batch_size
		}
	}
	ingest: {
		batch_size: units.#Size
	}
}

resources: [Name=string]: #Resource
