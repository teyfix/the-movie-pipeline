import { d } from '@/db/api';
import { schema } from '@/db/schema';
import { unknownTitleColumns } from '@/db/schema/tables/title';
import { countryCode, languageCode, mongoId } from '@/db/shapes';

export const titleVideo = schema.table(
  'title_video',
  {
    id: mongoId().notNull(),
    /**
     * @description YouTube video key
     * @example "y2ZJ3lTaREY"
     */
    key: d.text().notNull(),
    name: d.text(),
    iso_3166_1: countryCode().notNull(),
    iso_639_1: languageCode().notNull(),
    official: d.boolean().notNull(),
    published_at: d.date().notNull(),
    /**
     * @example
     * - "YouTube"
     * - "Vimeo"
     */
    site: d.text().notNull(),
    /**
     * @example 1080
     */
    size: d.smallint().notNull(),
    /**
     * @example // Movie
     * - "Trailer"
     * - "Clip"
     * - "Teaser"
     * - "Featurette"
     * - "Behind the Scenes"
     * - "Bloopers"
     *
     * @example // TV Series
     * - "Opening Credits"
     * - "Trailer"
     * - "Clip"
     * - "Behind the Scenes"
     * - "Featurette"
     * - "Teaser"
     * - "Bloopers"
     */
    type: d.text().notNull(),

    ...unknownTitleColumns,
  },
  (t) => [d.primaryKey({ columns: [t.id] })],
);
