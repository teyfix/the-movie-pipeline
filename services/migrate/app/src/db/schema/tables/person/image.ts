import { d } from '@/db/api';
import { schema } from '@/db/schema';
import { imagePath } from '@/db/shapes';
import { personColumns } from '../person';

export const personImageKind = schema.enum('person_image_kind', ['profiles']);

export const personImage = schema.table(
  'person_image',
  {
    kind: personImageKind().notNull(),
    file_path: imagePath().notNull(),

    aspect_ratio: d.numeric().notNull(),

    width: d.smallint().notNull(),
    height: d.smallint().notNull(),

    vote_average: d.numeric().notNull(),
    vote_count: d.integer().notNull(),

    ...personColumns,
  },
  (t) => [d.primaryKey({ columns: [t.person_id, t.kind, t.file_path] })],
);
