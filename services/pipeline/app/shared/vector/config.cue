package vector

export: {
	"vector/config": {
		data_dir: "${DATADIR_VECTOR:?}"

		api: {
			enabled: true
			address: "0.0.0.0:8686"
		}

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
