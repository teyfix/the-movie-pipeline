package tmdb

resources: show: ingest: streams: common.ingest.title_parent & {
	title_show: {
		mapping: {
			unarchive: false
		}
		output: {
			table: "title_show"
			primary: ["title_id"]
			columns: [
				"number_of_episodes",
				"number_of_seasons",
				"last_air_date",
				"in_production",
				"last_episode_id",
				"next_episode_id",
				"type",
				"version_ts",
			]
		}
	}
	created_by: {
		output: {
			table: "title_created_by"
			primary: ["title_id", "person_id"]
			columns: ["version_ts"]
		}
	}
	content_rating: {
		output: {
			table: "title_content_rating"
			primary: ["title_id", "iso_3166_1"]
			columns: ["rating", "descriptors", "version_ts"]
		}
	}
	episode_group: {
		output: {
			table: "title_episode_group"
			primary: ["id"]
			columns: [
				"name",
				"description",
				"group_count",
				"episode_count",
				"type",
				"company_id",
				"title_id",
				"version_ts",
			]
		}
	}
	screened_theatrically: {
		output: {
			table: "title_screened_theatrically"
			primary: ["id"]
			columns: ["season_number", "episode_number", "title_id", "version_ts"]
		}
	}
}
