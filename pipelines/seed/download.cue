package seed

import "pipelines.lokal/shared/tmdb"

download: {
	sources: {
		for name , resource in tmdb.resources {
			for prefix in resource.download.prefix {
				"tmdb_download_\(prefix)": {
					type:               "exec"
					mode:               "scheduled"
					exec_interval_secs: "${TMDB_DOWNLOAD_INTERVAL_SECS:?}"
					command: ["bash", "/home/${USERNAME:?}/pipelines/download.sh"]
					environment: {
						KIND:               resource.kind
						PREFIX:             prefix
						TMDB_FILES_API_URL: "${TMDB_FILES_API_URL:?}"
						TMDB_DOWNLOAD_DIR:  "${TMDB_DOWNLOAD_DIR:?}"
					}
					decoding: {
						codec: "json"
					}
				}
			}
		}
	}

	transforms: {
		tmdb_download_metrics: {
			type: "log_to_metric"
			inputs: ["tmdb_download_*"]
			metrics: [{
				type:  "counter"
				field: "status"
				name:  "tmdb_downloads_total"
				tags: {
					kind:   "{{ kind }}"
					status: "{{ status }}"
					prefix: "{{ prefix }}"
				}
			}]
		}
	}
}
