package tmdb

resources: movie: ingest: streams: common.ingest.title_parent & {
	title_movie: {
		mapping: {
			unarchive: false
		}
		output: {
			table: "title_movie"
			primary: ["title_id"]
			columns: [
				"budget",
				"revenue",
				"runtime",
				"imdb_id",
				"collection_id",
				"video",
				"version_ts",
			]
		}
	}
	release_date: {
		output: {
			table: "title_release_date"
			primary: ["title_id", "iso_3166_1", "type", "release_date"]
			columns: ["certification", "descriptors", "iso_639_1", "note", "version_ts"]
		}
	}
}
