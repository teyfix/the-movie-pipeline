import { d } from '@/db/api';
import { schema } from '@/db/schema';
import { unknownTitleColumns } from '@/db/schema/tables/title';

export const titleList = schema.table(
  'title_list',
  {
    list_id: d.integer().notNull(),

    ...unknownTitleColumns,
  },
  (t) => [d.primaryKey({ columns: [t.title_id, t.title_kind, t.list_id] })],
);
