import { d } from '@/db/api';
import { schema } from '@/db/schema';
import { knownTitleColumns } from '@/db/schema/tables/title';
import { countryCode } from '@/db/shapes';

export const titleContentRating = schema.table(
  'title_content_rating',
  {
    iso_3166_1: countryCode().notNull(),
    /**
     * @example
     * - "PG13"
     * - "Children"
     * - "Exempt"
     */
    rating: d.text().notNull(),
    /**
     * Region-specific content advisory descriptors associated with the rating.
     * Some regions may use abbreviated classification codes.
     *
     * @example // US
     * - "Violence"
     * - "Coarse Language"
     *
     * @example // AU
     * - "Violence"
     * - "Fear"
     *
     * @example // CA film
     * - "V"
     */
    descriptors: d.text().array().notNull(),

    ...knownTitleColumns,
  },
  (t) => [d.primaryKey({ columns: [t.title_id, t.iso_3166_1] })],
);
