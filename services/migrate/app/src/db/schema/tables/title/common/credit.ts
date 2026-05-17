import { d } from '@/db/api';
import { schema } from '@/db/schema';
import { unknownTitleColumns } from '@/db/schema/tables/title';
import { mongoId, versionColumn } from '@/db/shapes';

export const creditKind = schema.enum('title_credit_kind', ['cast', 'crew']);

export const titleCredit = schema.table(
  'title_credit',
  {
    credit_id: mongoId().notNull(),
    person_id: d.integer().notNull(),
    kind: creditKind().notNull(),

    /**
     * Only available for episodes
     */
    guest: d.boolean().notNull().default(false),

    ...unknownTitleColumns,
  },
  (t) => [d.primaryKey({ columns: [t.credit_id] })],
);

export const titleCreditCast = schema.table(
  'title_credit_cast',
  {
    credit_id: mongoId().notNull(),

    /**
     * Only available for movies
     */
    cast_id: d.integer(),
    order: d.integer().notNull(),
    character: d.text(),

    ...versionColumn,
  },
  (t) => [d.primaryKey({ columns: [t.credit_id] })],
);

export const titleCreditCrew = schema.table(
  'title_credit_crew',
  {
    credit_id: mongoId().notNull(),

    department: d.text().notNull(),
    job: d.text().notNull(),

    ...versionColumn,
  },
  (t) => [d.primaryKey({ columns: [t.credit_id] })],
);
