import { d } from '../../api';
import { schema } from '../../schema';
import {
  auditColumns,
  imagePath,
  languageCode,
  versionColumn,
} from '../../shapes';

export const titleKind = schema.enum('title_kind', [
  'movie',
  'show',
  'season',
  'episode',
]);

export const title = schema.table(
  'title',
  {
    id: d.integer().notNull(),
    kind: titleKind().notNull(),
    name: d.text().notNull(),
    original_name: d.text().notNull(),
    original_language: languageCode().notNull(),
    backdrop_path: imagePath(),
    homepage: d.text(),
    overview: d.text(),
    tagline: d.text(),
    popularity: d.numeric().notNull(),
    poster_path: imagePath(),
    release_date: d.date(),
    softcore: d.boolean().notNull(),
    status: d.text().notNull(),
    vote_average: d.numeric().notNull(),
    vote_count: d.integer().notNull(),
    adult: d.boolean().notNull(),
    ...auditColumns,
    ...versionColumn,
  },
  (t) => [d.primaryKey({ columns: [t.id, t.kind] })],
);

export const unknownTitleColumns = {
  title_id: d.integer().notNull(),
  title_kind: titleKind().notNull(),
  ...versionColumn,
};

export const knownTitleColumns = {
  title_id: d.integer().notNull(),
  ...versionColumn,
};
