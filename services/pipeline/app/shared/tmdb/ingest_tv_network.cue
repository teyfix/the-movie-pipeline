package tmdb

resources: tv_network: ingest: streams: {
	company: {
		mapping: {
			from:      ".company/company.blobl"
			unarchive: false
		}
		output: {
			table: "company"
			primary: ["id", "kind"]
			columns: [
				"name",
				"headquarters",
				"homepage",
				"logo_path",
				"origin_country",
			]
			updated_at: true
		}
	}
}
