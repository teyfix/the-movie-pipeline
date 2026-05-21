package tmdb

common: ingest: title_common: {
	company: {
		mapping: {
			from: ".title/company.blobl"
		}
		output: {
			table: "title_company"
			primary: ["title_id", "title_kind", "company_id", "company_kind"]
			columns: ["version_ts"]
		}
	}
	credit: {
		mapping: {
			from: ".title/credit.blobl"
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
	credit_cast: {
		mapping: {
			from: ".title/credit_cast.blobl"
		}
		output: {
			table: "title_credit_cast"
			primary: ["credit_id"]
			columns: ["cast_id", "order", "character", "version_ts"]
		}
	}
	credit_crew: {
		mapping: {
			from: ".title/credit_crew.blobl"
		}
		output: {
			table: "title_credit_crew"
			primary: ["credit_id"]
			columns: ["job", "department", "version_ts"]
		}
	}
	translation: {
		mapping: {
			from: ".title/translation.blobl"
		}
		output: {
			table: "title_translation"
			primary: ["title_id", "title_kind", "iso_3166_1", "iso_639_1", "field"]
			columns: ["value", "version_ts"]
		}
	}
	video: {
		mapping: {
			from: ".title/video.blobl"
		}
		output: {
			table: "title_video"
			primary: ["id"]
			columns: [
				"key",
				"name",
				"iso_3166_1",
				"iso_639_1",
				"official",
				"published_at",
				"site",
				"size",
				"type",
				"title_id",
				"title_kind",
				"version_ts",
			]
		}
	}
}
