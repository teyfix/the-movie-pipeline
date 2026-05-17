import { d } from '../../api';
import { schema } from '../../schema';
import { auditColumns, countryCode, imagePath } from '../../shapes';

export const companyKind = schema.enum('company_kind', [
  'production_company',
  'tv_network',
]);

export const company = schema.table(
  'company',
  {
    id: d.integer().notNull(),
    kind: companyKind().notNull(),
    name: d.text().notNull(),
    description: d.text(),
    homepage: d.text(),
    headquarters: d.text(),
    /**
     * `.notNull()` can be added if you're not using 
     * `passthrough: true` for `production-company` or `tv-network`
     */
    origin_country: countryCode(), // .notNull(),
    logo_path: imagePath(),
    parent_company: d.integer(),
    ...auditColumns,
  },
  (t) => [d.primaryKey({ columns: [t.id, t.kind] })],
);

export const companyJoinColumns = {
  company_id: d.integer().notNull(),
  company_kind: companyKind().notNull(),
};
