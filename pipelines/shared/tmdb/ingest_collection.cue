package tmdb

resources: collection: ingest: {
	kafka: {
		batch_size: "2mb"
	}

	streams: {
		collection: {
			mapping: {
				unarchive: false
			}
			output: {
				table: "colleection"
				primary: ["id"]
				columns: [
					"id",
					"name",
					"overview",
					"poster_path",
					"backdrop_path",
					"original_name",
					"original_language",
					"version_ts",
				]
				updated_at: true
			}
		}
		collection_part: {
			output: {
				table: "collection_part"
				primary: ["collection_id", "part_id"]
				columns: ["part_index", "media_type", "version_ts"]
			}
		}
	}
}
