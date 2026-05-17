import { d } from '../../api';
import { schema } from '../../schema';
import { languageCode } from '../../shapes';

export const language = schema.table(
  'language',
  {
    iso_639_1: languageCode().notNull(),
    name: d.text(),
    english_name: d.text().notNull(),
  },
  (t) => [d.primaryKey({ columns: [t.iso_639_1] })],
);
