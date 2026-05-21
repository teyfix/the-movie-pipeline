package tmdb

resources: production_company: ingest: streams: {
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
				"description",
				"headquarters",
				"homepage",
				"logo_path",
				"origin_country",
				"parent_company",
			]
			updated_at: true
		}
	}
}
