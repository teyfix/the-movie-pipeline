import { d } from '../../api';
import { schema } from '../../schema';
import { countryCode } from '../../shapes';

export const country = schema.table(
  'country',
  {
    iso_3166_1: countryCode().notNull(),
    name: d.text().notNull(),
  },
  (t) => [d.primaryKey({ columns: [t.iso_3166_1] })],
);
