import { d } from '@/db/api';
import { schema } from '@/db/schema';
import { countryCode, languageCode } from '@/db/shapes';
import { knownTitleColumns } from '../../title';

export const titleReleaseDate = schema.table(
  'title_release_date',
  {
    certification: d.text(),
    descriptors: d.text().array().notNull(),
    iso_3166_1: countryCode().notNull(),
    iso_639_1: languageCode(),
    note: d.text(),
    release_date: d.date().notNull(),
    type: d.integer().notNull(),

    ...knownTitleColumns,
  },
  (t) => [
    d.primaryKey({
      columns: [t.title_id, t.iso_3166_1, t.type, t.release_date],
    }),
  ],
);
