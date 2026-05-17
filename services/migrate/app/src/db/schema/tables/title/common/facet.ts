import { d } from '@/db/api';
import { schema } from '@/db/schema';
import { unknownTitleColumns } from '@/db/schema/tables/title';
import { facetKind } from '../../facet';

export const titleFacet = schema.table(
  'title_facet',
  {
    facet_id: d.integer().notNull(),
    facet_kind: facetKind().notNull(),

    ...unknownTitleColumns,
  },
  (t) => [
    d.primaryKey({
      columns: [t.title_id, t.title_kind, t.facet_id, t.facet_kind],
    }),
  ],
);
