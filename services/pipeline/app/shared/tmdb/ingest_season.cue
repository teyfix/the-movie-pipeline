package tmdb

resources: season: ingest: streams: common.ingest.title_common & {
	season: {
		mapping: {
			unarchive: false
		}
		output: {
			table: "title_season"
			primary: ["id"]
			columns: [
				"_id",
				"name",
				"overview",
				"air_date",
				"season_number",
				"poster_path",
				"vote_average",
				"title_id",
				"version_ts",
			]
		}
	}
	episode: {
		output: {
			table: "title_episode"
			primary: ["id"]
			columns: [
				"season_number",
				"episode_number",
				"name",
				"episode_type",
				"air_date",
				"overview",
				"production_code",
				"still_path",
				"runtime",
				"vote_average",
				"vote_count",
				"title_id",
				"version_ts",
			]
		}
	}
	episode_credit: {
		mapping: {
			drop_error: true
		}
		output: {
			table: "title_credit"
			primary: ["credit_id"]
			columns: [
				"person_id",
				"kind",
				"guest",
				"title_id",
				"title_kind",
				"version_ts",
			]
		}
	}
	episode_credit_cast: {
		mapping: {
			drop_error: true
		}
		output: {
			table: "title_credit_cast"
			primary: ["credit_id"]
			columns: ["cast_id", "order", "character", "version_ts"]
		}
	}
	episode_credit_crew: {
		output: {
			table: "title_credit_crew"
			primary: ["credit_id"]
			columns: ["job", "department", "version_ts"]
		}
	}
}
