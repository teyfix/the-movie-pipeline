package tmdb

resources: movie_embed: ingest: streams: {
	title_embed: {
		mapping: {
			from:      ".title/embed.blobl"
			unarchive: false
		}
		output: {
			table: "title_embed"
			primary: ["title_id", "title_kind", "model_id"]
			columns: ["model_dimensions", "input", "embedding", "version_ts"]
		}
	}
}
