package tmdb

resources: {
	movie: {
		kind: "movie"
		topic: {
			embed:      "tmdb.embed.movie"
			export:     "tmdb.export.movie"
			detail:     "tmdb.detail.movie"
			normalized: "tmdb.normalized.movie"
		}
		consumer: {
			enrich:    "tmdb.enrich.movie.v1"
			normalize: "tmdb.normalize.movie.v1"
			embed:     "tmdb.embed.movie.v1"
			ingest:    "tmdb.ingest.movie.v1"
		}
		download: prefix: ["movie", "adult_movie"]
		enrich: {
			min_popularity: 1
			endpoint:       "/3/movie/%s?append_to_response=alternative_titles,credits,images,keywords,lists,recommendations,release_dates,reviews,similar,translations,videos,watch_providers"
		}
		ingest: batch_size: "30mb"
	}
	show: {
		kind: "show"
		topic: {
			export:     "tmdb.export.show"
			detail:     "tmdb.detail.show"
			normalized: "tmdb.normalized.show"
		}
		consumer: {
			enrich:    "tmdb.enrich.show.v1"
			normalize: "tmdb.normalize.show.v1"
			embed:     "tmdb.embed.show.v1"
			ingest:    "tmdb.ingest.show.v1"
		}
		download: prefix: ["tv_series", "adult_tv_series"]
		enrich: {
			min_popularity: 2
			endpoint:       "/3/tv/%s?append_to_response=alternative_titles,content_ratings,credits,episode_groups,images,keywords,lists,recommendations,reviews,screened_theatrically,similar,translations,videos,watch_providers"
		}
		ingest: batch_size: "16mb"
	}
	person: {
		kind: "person"
		topic: {
			export:     "tmdb.export.person"
			detail:     "tmdb.detail.person"
			normalized: "tmdb.normalized.person"
		}
		consumer: {
			enrich:    "tmdb.enrich.person.v1"
			normalize: "tmdb.normalize.person.v1"
			embed:     "tmdb.embed.person.v1"
			ingest:    "tmdb.ingest.person.v1"
		}
		download: prefix: ["person", "adult_person"]
		enrich: {
			min_popularity: 0.8
			endpoint:       "/3/person/%s?append_to_response=images,movie_credits,tagged_images,translations,tv_credits"
		}
		ingest: batch_size: "24mb"
	}
	collection: {
		kind: "collection"
		topic: {
			export:     "tmdb.export.collection"
			detail:     "tmdb.detail.collection"
			normalized: "tmdb.normalized.collection"
		}
		consumer: {
			enrich:    "tmdb.enrich.collection.v1"
			normalize: "tmdb.normalize.collection.v1"
			embed:     "tmdb.embed.collection.v1"
			ingest:    "tmdb.ingest.collection.v1"
		}
		download: prefix: ["collection"]
		enrich: {
			min_popularity: 0
			endpoint:       "/3/collection/%s"
		}
		ingest: batch_size: "2mb"
	}
	tv_network: {
		kind: "tv_network"
		topic: {
			export:     "tmdb.export.tv-network"
			detail:     "tmdb.detail.tv-network"
			normalized: "tmdb.normalized.tv-network"
		}
		consumer: {
			enrich:    "tmdb.enrich.tv-network.v1"
			normalize: "tmdb.normalize.tv-network.v1"
			embed:     "tmdb.embed.tv-network.v1"
			ingest:    "tmdb.ingest.tv-network.v1"
		}
		download: prefix: ["tv_network"]
		enrich: {
			min_popularity: 0
			endpoint:       "/3/network/%s"
			passthrough:    true
		}
		ingest: batch_size: "200kb"
	}
	keyword: {
		kind: "keyword"
		topic: {
			export:     "tmdb.export.keyword"
			detail:     "tmdb.detail.keyword"
			normalized: "tmdb.normalized.keyword"
		}
		consumer: {
			enrich:    "tmdb.enrich.keyword.v1"
			normalize: "tmdb.normalize.keyword.v1"
			embed:     "tmdb.embed.keyword.v1"
			ingest:    "tmdb.ingest.keyword.v1"
		}
		download: prefix: ["keyword"]
		enrich: {
			min_popularity: 0
			endpoint:       "/3/keyword/%s"
			passthrough:    true
		}
		ingest: batch_size: "100kb"
	}
	production_company: {
		kind: "production-company"
		topic: {
			export:     "tmdb.export.production-company"
			detail:     "tmdb.detail.production-company"
			normalized: "tmdb.normalized.production-company"
		}
		consumer: {
			enrich:    "tmdb.enrich.production-company.v1"
			normalize: "tmdb.normalize.production-company.v1"
			embed:     "tmdb.embed.production-company.v1"
			ingest:    "tmdb.ingest.production-company.v1"
		}
		download: prefix: ["production_company"]
		enrich: {
			min_popularity: 0
			endpoint:       "/3/company/%s"
			passthrough:    true
		}
		ingest: batch_size: "200kb"
	}
}
extras: season: {
	kind: "season"
	topic: {
		detail:     "tmdb.detail.season"
		normalized: "tmdb.normalized.season"
	}
	consumer: {
		enrich:    "tmdb.enrich.season.v1"
		normalize: "tmdb.normalize.season.v1"
		ingest:    "tmdb.ingest.season.v1"
	}
	enrich: {
		min_popularity: 0
		endpoint:       "/3/tv/%s/season/%s?append_to_response=credits,images,translations,videos,watch_providers"
	}
	ingest: batch_size: "20mb"
}
