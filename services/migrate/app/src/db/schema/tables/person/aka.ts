import { d } from '@/db/api';
import { schema } from '@/db/schema';
import { personColumns } from '../person';

export const personAka = schema.table(
  'person_aka',
  {
    also_known_as: d.text().notNull(),

    ...personColumns,
  },
  (t) => [d.primaryKey({ columns: [t.person_id, t.also_known_as] })],
);
