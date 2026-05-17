import { d } from '../../api';
import { schema } from '../../schema';
import {
  auditColumns,
  imagePath,
  versionColumn,
} from '../../shapes';

export const person = schema.table(
  'person',
  {
    id: d.integer().notNull(),
    name: d.text().notNull(),
    biography: d.text(),
    birthday: d.date(),
    deathday: d.date(),
    gender: d.integer().notNull(),
    homepage: d.text(),
    imdb_id: d.text(),
    known_for_department: d.text(),
    /**
     * @example "Reykjavík, Iceland"
     */
    place_of_birth: d.text(),
    popularity: d.numeric().notNull(),
    profile_path: imagePath(),
    adult: d.boolean().notNull(),
    ...auditColumns,
    ...versionColumn,
  },
  (t) => [d.primaryKey({ columns: [t.id] })],
);

export const personColumns = {
  person_id: d.integer().notNull(),
  ...versionColumn,
};
