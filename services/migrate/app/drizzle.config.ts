import { defineConfig } from 'drizzle-kit';
import { Config } from './src/config';

export default defineConfig({
  dialect: 'postgresql',
  schema: ['src/db/schema/**/*.ts'],
  out: Config.MIGRATION_PATH,
  dbCredentials: {
    url: Config.POSTGRES_URL,
  },
});
