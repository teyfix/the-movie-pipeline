package tmdb

resources: {
	movie: {
		kind: "movie"
		download: prefix: ["movie", "adult_movie"]
		enrich: {
			filter: min_popularity: 1
			api: endpoint:          "/3/movie/{{ data.id }}?append_to_response=alternative_titles,credits,images,keywords,lists,recommendations,release_dates,reviews,similar,translations,videos,watch_providers"
		}
		normalize: {
			kafka: {
				batch_size: "30mb"
			}
		}
		embed: {}
		ingest: {
			kafka: {
				batch_size: "30mb"
			}
		}
	}
	movie_embed: {
		kind: "movie"
		topic: {
			detail:     "\(nsp).normalized.movie"
			normalized: "\(nsp).embed.movie"
		}
		ingest: {
			kafka: {
				batch_size: "30mb"
			}
		}
	}
	show: {
		kind: "show"
		download: prefix: ["tv_series", "adult_tv_series"]
		enrich: {
			filter: min_popularity: 2
			api: endpoint:          "/3/tv/{{ data.id }}?append_to_response=alternative_titles,content_ratings,credits,episode_groups,images,keywords,lists,recommendations,reviews,screened_theatrically,similar,translations,videos,watch_providers"
		}
		normalize: {
			kafka: {
				batch_size: "16mb"
			}
		}
		ingest: {
			kafka: {
				batch_size: "16mb"
			}
		}
	}
	person: {
		kind: "person"
		download: prefix: ["person", "adult_person"]
		enrich: {
			api: endpoint: "/3/person/{{ data.id }}?append_to_response=images,movie_credits,tagged_images,translations,tv_credits"
		}
		normalize: {
			kafka: {
				batch_size: "24mb"
			}
		}
		ingest: {
			kafka: {
				batch_size: "24mb"
			}
		}
	}
	collection: {
		kind: "collection"
		download: prefix: ["collection"]
		enrich: {
			api: endpoint: "/3/collection/{{ data.id }}"
		}
		normalize: {
			kafka: {
				batch_size: "2mb"
			}
		}
		ingest: {
			kafka: {
				batch_size: "2mb"
			}
		}
	}
	tv_network: {
		kind: "tv_network"
		download: prefix: ["tv_network"]
		enrich: {
			api: {
				endpoint:    "/3/network/{{ data.id }}"
				passthrough: true
			}
		}
		normalize: {
			kafka: {
				batch_size: "200kb"
			}
		}
		ingest: {
			kafka: {
				batch_size: "200kb"
			}
		}
	}
	keyword: {
		kind: "keyword"
		download: prefix: ["keyword"]
		enrich: {
			api: {
				endpoint:    "/3/keyword/{{ data.id }}"
				passthrough: true
			}
		}
		normalize: {
			kafka: {
				batch_size: "100kb"
			}
		}
		ingest: {
			kafka: {
				batch_size: "100kb"
			}
		}
	}
	production_company: {
		kind: "production_company"
		download: prefix: ["production_company"]
		enrich: {
			api: {
				endpoint:    "/3/company/{{ data.id }}"
				passthrough: true
			}
		}
		normalize: {
			kafka: {
				batch_size: "200kb"
			}
		}
		ingest: {
			kafka: {
				batch_size: "200kb"
			}
		}
	}
	season: {
		kind: "season"
		enrich: {
			api: endpoint: "/3/tv/{{ data.id }}/season/{{ data.season.season_number }}?append_to_response=credits,images,translations,videos,watch_providers"
			transform: {
				mapping: true
			}
			kafka: {
				batch_size:  "5mb"
				buffer_size: "10mb"
			}
		}
		normalize: {
			kafka: {
				batch_size: "20mb"
			}
		}
		ingest: {
			kafka: {
				batch_size: "20mb"
			}
		}
	}
}
