package tmdb

import units "pipelines.lokal/shared/units"

#CommonTopic: {
	embed?:     string
	detail:     string
	normalized: string
}

#CommonConsumer: {
	enrich:    string
	normalize: string
	embed?:    string
	ingest:    string
}

#Enrich: {
	min_popularity: number | *0
	endpoint:       string
	passthrough:    bool | *false
}

#Ingest: {
	batch_size: units.#Size
}

#Resource: {
	kind: string
	topic: #CommonTopic & {
		export: string
	}
	consumer: #CommonConsumer
	download: {
		prefix: [...string]
	}
	enrich: #Enrich
	ingest: #Ingest
}

#Extra: {
	kind:     string
	topic:    #CommonTopic
	consumer: #CommonConsumer
	enrich:   #Enrich
}

resources: [Name=string]: #Resource
extras: [Name=string]:    #Extra
