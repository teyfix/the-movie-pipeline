import { d } from '@/db/api';
import { schema } from '@/db/schema';
import { unknownTitleColumns } from '@/db/schema/tables/title';
import { languageCode } from '@/db/shapes';

export const titleLanguage = schema.table(
  'title_language',
  {
    iso_639_1: languageCode().notNull(),

    ...unknownTitleColumns,
  },
  (t) => [d.primaryKey({ columns: [t.title_id, t.title_kind, t.iso_639_1] })],
);
