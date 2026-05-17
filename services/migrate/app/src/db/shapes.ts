import { TSchema } from '@sinclair/typebox';
import { sql } from 'drizzle-orm';
import { ExtraConfigColumn } from 'drizzle-orm/cockroach-core';
import { d } from './api';
import { schema } from './schema';

/**
 * Shared audit timestamp columns, appended to tables that need row-level change tracking.
 *
 * Uses `*_ts` suffix convention to avoid naming conflicts with TMDB's own `*_at` fields.
 */
export const auditColumns = {
  /** Timestamp of row insertion, set automatically by the database. */
  created_ts: d.timestamp().notNull().defaultNow(),
  /** Timestamp of last row update, set automatically by the database. */
  updated_ts: d.timestamp().notNull().defaultNow(),
};

/**
 * Ingestion watermark column, appended to tables sourced from the daily publish Vector pipeline.
 *
 * Used to identify the latest valid snapshot when joining tables, and to suppress stale data
 * that may arrive out of order.
 *
 * @example
 * ```sql
 * SELECT *
 * FROM "title" t
 * JOIN "title_company" tc
 *   ON t.id = tc.title_id
 *   AND t.version_ts = tc.version_ts -- ensures stale rows are excluded
 * ```
 */
export const versionColumn = {
  version_ts: d.timestamp().notNull(),
};

/**
 * [ISO 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) language code (`en`, `pt`, …).
 *
 * TMDB typically pairs this with an ISO 3166-1 country code: `en-US`, `pt-BR`.
 * Note: some languages lack an ISO 639-1 representation; TMDB may upgrade to ISO 639-3 in future.
 *
 * @see https://developer.themoviedb.org/docs/languages
 */
export const languageCode = d.text;

/**
 * [ISO 3166-1 alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country code (`US`, `BR`, …).
 *
 * TMDB pairs this with an ISO 639-1 language code to form locale strings like `en-US`.
 *
 * @see https://developer.themoviedb.org/docs/languages#iso-3166-1
 */
export const countryCode = d.text;

/**
 * Relative path to a TMDB-hosted image, e.g. `/1E5baAaEse26fej7uHcjOgEE2t2.jpg`.
 *
 * Combine with a base URL and size from the `/configuration` endpoint to form a full URL:
 * ```
 * https://image.tmdb.org/t/p/w500/1E5baAaEse26fej7uHcjOgEE2t2.jpg
 * ```
 *
 * SVG logos (e.g. network logos) should be fetched at `original` size; PNG variants are
 * available at any standard size.
 *
 * @see https://developer.themoviedb.org/docs/image-basics
 */
export const imagePath = d.text;

/**
 * [MongoDB ObjectId](https://www.mongodb.com/docs/manual/reference/method/ObjectId/) stored as `bytea`.
 *
 * Certain TMDB API fields are MongoDB ObjectIds. Storing as raw bytes is more space-efficient
 * than text and preserves the binary representation for integrity checks during ingestion.
 *
 * String values must be padded with `00000000` during ingestion to ensure they are 32 characters long.
 */
export const mongoId = d.uuid;

/**
 * Generates a SQL expression that validates a JSONB column against a TypeBox schema.
 *
 * @param T - The TypeBox schema to validate against.
 * @param column - The JSONB column to validate.
 * @returns A Drizzle SQL expression for use in CHECK constraints or WHERE clauses.
 */
export const jsonbMatchesSchema = <T extends TSchema>(
  T: T,
  column: ExtraConfigColumn,
) => sql`
  ${schema}.jsonb_matches_schema (
    ${JSON.stringify(T, null, 2)},
    ${column}
  )
`;
