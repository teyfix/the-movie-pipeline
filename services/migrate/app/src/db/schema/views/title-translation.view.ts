import { schema } from '@/db/schema';
import { InferEnum, SQL, sql } from 'drizzle-orm';
import {
  titleField,
  titleTranslation,
} from '../tables/title/common/translation';

type Translation = Partial<Record<InferEnum<typeof titleField>, string>> & {
  iso_3166_1: string;
  iso_639_1: string;
};

export const titleTranslationView = schema
  .view('title_translation_view')
  .as((qb) => {
    const tr = qb
      .select({
        title_id: titleTranslation.title_id,
        title_kind: titleTranslation.title_kind,
        version_ts: titleTranslation.version_ts,
        translation: sql`
          jsonb_build_object(
            'iso_3166_1',
            ${titleTranslation.iso_3166_1},
            'iso_639_1',
            ${titleTranslation.iso_639_1}
          ) || jsonb_object_agg(
            ${titleTranslation.field}::TEXT,
            ${titleTranslation.value}
          )
        `.as('translation') as SQL.Aliased<Translation>,
      })
      .from(titleTranslation)
      .groupBy(
        titleTranslation.title_id,
        titleTranslation.title_kind,
        titleTranslation.iso_3166_1,
        titleTranslation.iso_639_1,
        titleTranslation.version_ts,
      )
      .as('sq_translations');

    return qb
      .select({
        id: tr.title_id,
        kind: tr.title_kind,
        version_ts: tr.version_ts,
        translations: sql<Translation[]>`
          array_remove(
            array_agg(${tr.translation}),
            NULL
          )
        `.as('translations'),
      })
      .from(tr)
      .groupBy(tr.title_id, tr.title_kind, tr.version_ts);
  });
