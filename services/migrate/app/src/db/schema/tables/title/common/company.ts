import { d } from '@/db/api';
import { schema } from '@/db/schema';
import { unknownTitleColumns } from '@/db/schema/tables/title';
import { companyKind } from '../../company';

export const titleCompany = schema.table(
  'title_company',
  {
    company_id: d.integer().notNull(),
    company_kind: companyKind().notNull(),

    ...unknownTitleColumns,
  },
  (t) => [
    d.primaryKey({
      columns: [t.title_id, t.title_kind, t.company_id, t.company_kind],
    }),
  ],
);
