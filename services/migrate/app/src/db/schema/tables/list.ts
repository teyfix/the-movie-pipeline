import { d } from '@/db/api';
import { schema } from '@/db/schema';
import { countryCode, imagePath, languageCode } from '@/db/shapes';

export const list = schema.table(
  'list',
  {
    id: d.integer().notNull(),
    name: d.text().notNull(),
    description: d.text(),
    iso_3166_1: countryCode().notNull(),
    iso_639_1: languageCode().notNull(),
    item_count: d.integer().notNull(),
    favorite_count: d.integer().notNull(),
    poster_path: imagePath(),
    list_type: d.text().notNull(),
  },
  (t) => [d.primaryKey({ columns: [t.id] })],
);
