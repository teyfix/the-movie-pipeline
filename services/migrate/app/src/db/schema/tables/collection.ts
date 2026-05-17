import { d } from '../../api';
import { schema } from '../../schema';
import {
  auditColumns,
  imagePath,
  languageCode,
  versionColumn,
} from '../../shapes';

export const collection = schema.table(
  'collection',
  {
    id: d.integer().notNull(),
    name: d.text().notNull(),
    original_name: d.text().notNull(),
    original_language: languageCode().notNull(),
    overview: d.text(),
    poster_path: imagePath(),
    backdrop_path: imagePath(),
    ...auditColumns,
    ...versionColumn,
  },
  (t) => [d.primaryKey({ columns: [t.id] })],
);

export const collectionPart = schema.table(
  'collection_part',
  {
    collection_id: d.integer().notNull(),
    part_id: d.integer().notNull(),
    /**
     * Type of this part within the collection.
     * All of the collection parts must logically share the same type.
     *
     * @example 'movie' | 'collection'
     */
    media_type: d.text().notNull(),
    /**
     * Auto generated index to preserve array order during ingestion
     */
    part_index: d.integer(),
    ...versionColumn,
  },
  (t) => [
    d.primaryKey({
      columns: [t.collection_id, t.part_id],
    }),
  ],
);
