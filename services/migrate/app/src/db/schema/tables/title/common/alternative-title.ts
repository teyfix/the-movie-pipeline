import { d } from '@/db/api';
import { schema } from '@/db/schema';
import { unknownTitleColumns } from '@/db/schema/tables/title';
import { countryCode } from '@/db/shapes';

export const titleAlternativeTitle = schema.table(
  'title_alternative_title',
  {
    iso_3166_1: countryCode().notNull(),
    title: d.text().notNull(),
    type: d.text(),

    ...unknownTitleColumns,
  },
  (t) => [
    d.primaryKey({
      columns: [t.title_id, t.title_kind, t.iso_3166_1, t.title],
    }),
  ],
);
