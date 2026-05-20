package ingest

import (
	"encoding/yaml"
	"tool/file"
)

command: "export": {
	mkdir: file.MkdirAll & {
		path: "ingest/streams"
	}

	for prop, data in exports {
		"write-\(prop)": file.Create & {
			$after: [mkdir]

			filename: "ingest/streams/\(prop).yaml"
			contents: yaml.Marshal(data)
		}
	}
}
