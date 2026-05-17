import { d } from '@/db/api';
import { schema } from '@/db/schema';
import { unknownTitleColumns } from '@/db/schema/tables/title';
import { mongoId } from '@/db/shapes';

export const titleReview = schema.table(
  'title_review',
  {
    id: mongoId().notNull(),
    author: d.text().notNull(),
    content: d.text().notNull(),
    url: d.text().notNull(),
    created_at: d.timestamp().notNull(),
    updated_at: d.timestamp().notNull(),

    author_avatar_path: d.text(),
    author_name: d.text(),
    author_rating: d.numeric(),
    author_username: d.text().notNull(),

    ...unknownTitleColumns,
  },
  (t) => [
    d.primaryKey({ columns: [t.id] }),
    d.index().on(t.title_id, t.title_kind, t.version_ts),
  ],
);
