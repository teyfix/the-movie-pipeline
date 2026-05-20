package connect

export: "connect/observability": {
	http: {
		enabled: true
		address: "0.0.0.0:4195"
	}

	logger: {
		format: "json"
	}

	metrics: {
		prometheus: {
			use_histogram_timing: true
			histogram_buckets: [0.001, 0.01, 0.1, 0.5, 1.0, 5.0, 10.0]
			add_process_metrics: true
			add_go_metrics:      true
		}
	}
}
