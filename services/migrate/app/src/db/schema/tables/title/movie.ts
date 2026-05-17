import { d } from '@/db/api';
import { schema } from '@/db/schema';
import { knownTitleColumns } from '../title';

export const titleMovie = schema.table(
  'title_movie',
  {
    budget: d.bigint({ mode: 'number' }).notNull(),
    revenue: d.bigint({ mode: 'number' }).notNull(),
    runtime: d.integer().notNull(),
    imdb_id: d.text(),
    collection_id: d.integer(),
    video: d.boolean().notNull(),

    ...knownTitleColumns,
  },
  (t) => [d.primaryKey({ columns: [t.title_id] })],
);
