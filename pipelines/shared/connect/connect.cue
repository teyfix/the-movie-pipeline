package connect

import units "pipelines.lokal/shared/units"

rate_limit_resources: [{
	label: string
	local: {
		count:    int
		interval: units.#Duration
	}
}]

processor_resources: [{
	label:   string
	mapping: string
}]
