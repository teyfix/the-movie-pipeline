import { d } from '@/db/api';
import { schema } from '@/db/schema';
import { titleKind, unknownTitleColumns } from '@/db/schema/tables/title';

export const titleRelationKind = schema.enum('title_relation_kind', [
  'similar',
  'recommendations',
]);

export const titleRelation = schema.table(
  'title_relation',
  {
    kind: titleRelationKind().notNull(),
    related_id: d.integer().notNull(),
    related_kind: titleKind().notNull(),

    ...unknownTitleColumns,
  },
  (t) => [
    d.primaryKey({
      columns: [t.title_id, t.title_kind, t.kind, t.related_id, t.related_kind],
    }),
  ],
);
