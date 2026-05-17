import { d } from '@/db/api';
import { schema } from '@/db/schema';
import { knownTitleColumns } from '../../title';

export const titleEpisode = schema.table(
  'title_episode',
  {
    id: d.integer().notNull(),
    show_id: d.integer(),
    season_number: d.smallint().notNull(),
    episode_number: d.smallint().notNull(),
    name: d.text().notNull(),
    episode_type: d.text().notNull(),
    air_date: d.timestamp(),
    overview: d.text(),
    production_code: d.text(),
    still_path: d.text(),
    runtime: d.smallint(),
    vote_average: d.numeric().notNull(),
    vote_count: d.integer().notNull(),

    ...knownTitleColumns,
  },
  (t) => [d.primaryKey({ columns: [t.id] })],
);
