import { Config } from '@/config';
import { d } from '@/db/api';
import { schema } from '@/db/schema';
import { unknownTitleColumns } from '../../title';

export const titleEmbed = schema.table(
  'title_embed',
  {
    model_id: d.text().notNull(),
    model_dimensions: d.smallint().notNull(),
    input: d.text().notNull(),
    embedding: d
      .halfvec({ dimensions: Config.EMBEDDING_DIMENSIONS_MAX })
      .notNull(),
    ...unknownTitleColumns,
  },
  (t) => [d.primaryKey({ columns: [t.title_id, t.title_kind, t.model_id] })],
);
