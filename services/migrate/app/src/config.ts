import env from 'env-var';

export const Config = {
  POSTGRES_URL: env.get('POSTGRES_URL').required().asUrlString(),
  POSTGRES_SCHEMA: env.get('POSTGRES_SCHEMA').required().asString(),
  MIGRATION_PATH: env.get('MIGRATION_PATH').default('./drizzle').asString(),
  EMBEDDING_DIMENSIONS_MAX: env
    .get('EMBEDDING_DIMENSIONS_MAX')
    .default('2048')
    .asIntPositive(),
};
