import { d } from '@/db/api';
import { schema } from '@/db/schema';
import { mongoId } from '@/db/shapes';
import { knownTitleColumns } from '../../title';

export const titleEpisodeGroup = schema.table(
  'title_episode_group',
  {
    id: mongoId().notNull(),
    name: d.text().notNull(),
    description: d.text(),
    group_count: d.integer().notNull(),
    episode_count: d.integer().notNull(),
    type: d.integer().notNull(),

    /**
     * company.id = company_id WHERE kind = 'tv_network'
     */
    company_id: d.integer(),

    ...knownTitleColumns,
  },
  (t) => [d.primaryKey({ columns: [t.id] })],
);
