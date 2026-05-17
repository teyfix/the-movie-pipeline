import { d } from '@/db/api';
import { schema } from '@/db/schema';
import { countryCode, languageCode } from '@/db/shapes';
import { personColumns } from '../person';

export const personField = schema.enum('person_field', ['name', 'biography']);

export const personTranslation = schema.table(
  'person_translation',
  {
    iso_3166_1: countryCode().notNull(),
    iso_639_1: languageCode().notNull(),

    field: personField().notNull(),
    value: d.text().notNull(),

    primary: d.boolean().notNull(),

    ...personColumns,
  },
  (t) => [
    d.primaryKey({
      columns: [t.person_id, t.iso_3166_1, t.iso_639_1, t.field],
    }),
  ],
);
