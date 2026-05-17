import { d } from '@/db/api';
import { schema } from '@/db/schema';
import { knownTitleColumns } from '../../title';

export const titleCreatedBy = schema.table(
  'title_created_by',
  {
    person_id: d.integer().notNull(),

    ...knownTitleColumns,
  },
  (t) => [d.primaryKey({ columns: [t.title_id, t.person_id] })],
);
