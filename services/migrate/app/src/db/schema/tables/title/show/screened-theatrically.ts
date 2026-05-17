import { d } from '@/db/api';
import { schema } from '@/db/schema';
import { knownTitleColumns } from '../../title';

export const titleScreenedTheatrically = schema.table(
  'title_screened_theatrically',
  {
    id: d.integer().notNull(),
    season_number: d.integer().notNull(),
    episode_number: d.integer(),

    ...knownTitleColumns,
  },
  (t) => [d.primaryKey({ columns: [t.id] })],
);
