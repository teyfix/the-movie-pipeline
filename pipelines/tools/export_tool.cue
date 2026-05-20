@experiment(try)

package tools

import (
	"encoding/yaml"
	"path"
	"tool/exec"
	"tool/file"
	"tool/os"
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
	config: os.Getenv & {
		APP_STAGE:  string | *"./out/stage"
		APP_TARGET: string | *"./out/target"
	}

	clean: exec.Run & {
		cmd: ["rm", "-rf", path.Join([config.APP_STAGE, "*"])]
	}

	create: [for prop, data in exports {
		let outfile = path.Join([config.APP_STAGE, prop])

		mkdir: file.MkdirAll & {
			$after: [clean]
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
		cmd: ["rsync", "--verbose", "--recursive", "--checksum", "--delete", config.APP_STAGE, config.APP_TARGET]
	}
}
