import { d } from '@/db/api';
import { schema } from '@/db/schema';
import { unknownTitleColumns } from '@/db/schema/tables/title';
import { countryCode } from '@/db/shapes';

export const titleCountryKind = schema.enum('title_country_kind', [
  'origin',
  'production',
]);

export const titleCountry = schema.table(
  'title_country',
  {
    kind: titleCountryKind().notNull(),
    iso_3166_1: countryCode().notNull(),

    ...unknownTitleColumns,
  },
  (t) => [
    d.primaryKey({ columns: [t.title_id, t.title_kind, t.kind, t.iso_3166_1] }),
  ],
);
