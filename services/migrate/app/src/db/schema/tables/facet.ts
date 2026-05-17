import { d } from '../../api';
import { schema } from '../../schema';
import { auditColumns } from '../../shapes';

export const facetKind = schema.enum('facet_kind', ['genres', 'keywords']);

export const facet = schema.table(
  'facet',
  {
    id: d.integer().notNull(),
    kind: facetKind().notNull(),
    name: d.text().notNull(),
    ...auditColumns,
  },
  (t) => [d.primaryKey({ columns: [t.id, t.kind] })],
);
