import { d } from '@/db/api';
import { schema } from '@/db/schema';
import { unknownTitleColumns } from '@/db/schema/tables/title';
import { countryCode, languageCode } from '@/db/shapes';

export const titleField = schema.enum('title_field', [
  'name',
  'overview',
  'tagline',
  'homepage',
  'runtime',
]);

export const titleTranslation = schema.table(
  'title_translation',
  {
    iso_3166_1: countryCode().notNull(),
    iso_639_1: languageCode().notNull(),
    /**
     * Aliased from `title` for movies
     */
    field: titleField().notNull(),
    value: d.text().notNull(),

    ...unknownTitleColumns,
  },
  (t) => [
    d.primaryKey({
      columns: [t.title_id, t.title_kind, t.iso_3166_1, t.iso_639_1, t.field],
    }),
  ],
);
