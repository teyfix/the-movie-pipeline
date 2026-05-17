import { d } from '@/db/api';
import { schema } from '@/db/schema';
import { knownTitleColumns } from '../title';

export const titleSeries = schema.table(
  'title_show',
  {
    number_of_episodes: d.integer(),
    number_of_seasons: d.integer().notNull(),
    last_air_date: d.date(),
    in_production: d.boolean().notNull(),
    last_episode_id: d.integer(),
    next_episode_id: d.integer(),
    /**
     * @example
     * - "Scripted"
     * - "Reality"
     * - "Miniseries"
     * - "Talk Show"
     * - "Documentary"
     * - "News"
     * - "Video"'
     */
    type: d.text().notNull(),

    ...knownTitleColumns,
  },
  (t) => [d.primaryKey({ columns: [t.title_id] })],
);
