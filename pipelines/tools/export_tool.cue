@experiment(try)

package tools

import (
	"encoding/yaml"
	"path"
	"tool/exec"
	"tool/file"
)

import (
	"pipelines.lokal/embed"
	"pipelines.lokal/enrich"
	"pipelines.lokal/ingest"
	"pipelines.lokal/normalize"
	"pipelines.lokal/seed"
)

exports:
	seed.export &
	enrich.export &
	normalize.export &
	embed.export &
	ingest.export &
	{}

command: "export": {
	let stage = "out/stage/"
	let target = "out/target/"

	create: [for prop, data in exports {
		let outfile = path.Join([stage, prop])

		mkdir: file.MkdirAll & {
			"path": path.Dir(outfile)
		}

		create: file.Create & {
			$after: [mkdir]
			filename: outfile
			contents: yaml.Marshal(data)
		}
	}]

	sync: exec.Run & {
		$after: [create]
		cmd: ["rsync", "--verbose", "--recursive", "--checksum", "--delete", stage, target]
	}
}
