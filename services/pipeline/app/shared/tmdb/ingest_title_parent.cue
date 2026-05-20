package tmdb

common: ingest: title_parent: common.ingest.title_common & {
	title: {
		mapping: {
			from:      ".title/title.blobl"
			unarchive: false
		}
		output: {
			table: "title"
			primary: ["id", "kind"]
			columns: [
				"name",
				"original_name",
				"original_language",
				"homepage",
				"overview",
				"tagline",
				"popularity",
				"release_date",
				"softcore",
				"status",
				"vote_average",
				"vote_count",
				"poster_path",
				"backdrop_path",
				"adult",
				"version_ts",
			]
			updated_at: true
		}
	}
	alternative_title: {
		mapping: {
			from: ".title/alternative_title.blobl"
		}
		output: {
			table: "title_alternative_title"
			primary: ["title_id", "title_kind", "iso_3166_1", "title"]
			columns: ["type", "version_ts"]
		}
	}
	country: {
		mapping: {
			from: ".shared/country.blobl"
		}
		output: {
			table: "country"
			primary: ["iso_3166_1"]
			columns: ["name"]
		}
	}
	title_country: {
		mapping: {
			from: ".title/country.blobl"
		}
		output: {
			table: "title_country"
			primary: ["title_id", "title_kind", "kind", "iso_3166_1"]
			columns: ["version_ts"]
		}
	}
	facet: {
		mapping: {
			from: ".shared/facet.blobl"
		}
		output: {
			table: "facet"
			primary: ["id", "kind"]
			columns: ["name"]
			updated_at: true
		}
	}
	title_facet: {
		mapping: {
			from: ".title/facet.blobl"
		}
		output: {
			table: "title_facet"
			primary: ["title_id", "title_kind", "facet_id", "facet_kind"]
			columns: ["version_ts"]
		}
	}
	language: {
		mapping: {
			from: ".shared/language.blobl"
		}
		output: {
			table: "language"
			primary: ["iso_639_1"]
			columns: ["name", "english_name"]
		}
	}
	title_language: {
		mapping: {
			from: ".title/language.blobl"
		}
		output: {
			table: "title_language"
			primary: ["title_id", "title_kind", "iso_639_1"]
			columns: ["version_ts"]
		}
	}
	image: {
		mapping: {
			from: ".title/image.blobl"
		}
		output: {
			table: "title_image"
			primary: ["title_id", "title_kind", "kind", "file_path"]
			columns: [
				"iso_639_1",
				"iso_3166_1",
				"width",
				"height",
				"aspect_ratio",
				"vote_average",
				"vote_count",
				"version_ts",
			]
		}
	}
	review: {
		mapping: {
			from: ".title/review.blobl"
		}
		output: {
			table: "title_review"
			primary: ["id"]
			columns: [
				"author",
				"content",
				"url",
				"created_at",
				"updated_at",
				"author_avatar_path",
				"author_name",
				"author_rating",
				"author_username",
				"title_id",
				"title_kind",
				"version_ts",
			]
		}
	}
	relation: {
		mapping: {
			from: ".title/relation.blobl"
		}
		output: {
			table: "title_relation"
			primary: ["title_id", "title_kind", "kind", "related_id", "related_kind"]
			columns: ["version_ts"]
		}
	}
	list: {
		mapping: {
			from: ".shared/list.blobl"
		}
		output: {
			table: "list"
			primary: ["id"]
			columns: [
				"name",
				"description",
				"iso_3166_1",
				"iso_639_1",
				"item_count",
				"favorite_count",
				"poster_path",
				"list_type",
			]
		}
	}
	title_list: {
		mapping: {
			from: ".title/list.blobl"
		}
		output: {
			table: "title_list"
			primary: ["list_id", "title_id", "title_kind"]
			columns: ["version_ts"]
		}
	}
}
