import { d } from '@/db/api';
import { schema } from '@/db/schema';
import { unknownTitleColumns } from '@/db/schema/tables/title';
import { countryCode, imagePath, languageCode } from '@/db/shapes';

export const titleImageKind = schema.enum('title_image_kind', [
  'backdrops',
  'logos',
  'posters',
]);

export const titleImage = schema.table(
  'title_image',
  {
    kind: titleImageKind().notNull(),
    file_path: imagePath().notNull(),
    iso_639_1: languageCode(),
    iso_3166_1: countryCode(),
    width: d.integer().notNull(),
    height: d.integer().notNull(),
    aspect_ratio: d.numeric().notNull(),
    vote_average: d.numeric().notNull(),
    vote_count: d.integer().notNull(),

    ...unknownTitleColumns,
  },
  (t) => [
    d.primaryKey({ columns: [t.title_id, t.title_kind, t.kind, t.file_path] }),
  ],
);
