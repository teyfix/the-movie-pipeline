# Sample Generator

Diagnostic service that consumes normalized Kafka topics and generates TypeScript type definitions.

## Purpose

- Inspect the shape of data on `tmdb.normalized.*` topics.
- Produce `.json` sample files and `.d.ts` type definitions using `quicktype`.
- Help develop Bloblang mappings and validate schema designs.

## How It Works

1. Consumes `N` messages from each normalized topic (`movie`, `show`, `person`, `season`, `collection`, `keyword`, `production-company`, `tv-network`).
2. Sanitizes JSON: empty strings → `null`, drops empty arrays/objects (optional via `jaq`).
3. Runs `quicktype` to generate TypeScript interfaces (PascalCase kind name).
4. Writes to `.volumes/sample/{kind}.json` and `{kind}.d.ts`.
5. Formats with `prettier` (only applies to generated typings).

## Usage

```bash
# Generate 100 samples (default)
docker compose --profile sample up -d

# Or via Taskfile
task sample count=1000
```

## Configuration

- `NUM_SAMPLE` — Number of messages to fetch per topic (default: 100).
- `ENABLE_JAQ` — Set to `true` to use `jaq` for advanced JSON sanitization.
- `KAFKA_BROKERS` — Internal broker address.

## Output

```text
.volumes/sample/
├── movie.json
├── movie.d.ts
├── show.json
├── show.d.ts
└── ...
```

**Note:** Fetching large sample counts (e.g., 10,000) can produce multi-megabyte files.
