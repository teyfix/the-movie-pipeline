import { d } from '@/db/api';
import { schema } from '@/db/schema';
import { mongoId } from '@/db/shapes';
import { knownTitleColumns } from '../../title';

export const titleSeason = schema.table(
  'title_season',
  {
    _id: mongoId('_id').notNull(),
    id: d.integer().notNull(),
    name: d.text().notNull(),
    overview: d.text(),
    air_date: d.date(),
    season_number: d.smallint().notNull(),
    poster_path: d.text(),
    vote_average: d.numeric().notNull(),

    ...knownTitleColumns,
  },
  (t) => [d.primaryKey({ columns: [t.id] })],
);
