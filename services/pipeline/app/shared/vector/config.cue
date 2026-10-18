package vector

export: {
	"vector/config": {
		healthchecks: {
			enabled: true
		}

		sources: {
			vector_metrics: {
				type:      "internal_metrics"
				namespace: "vector"
			}
		}

		sinks: {
			prometheus_exporter: {
				type: "prometheus_exporter"
				inputs: ["vector_metrics", "tmdb_download_metrics"]
				address:           "0.0.0.0:9598"
				flush_period_secs: 86400
			}
		}
	}
}
