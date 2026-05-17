import { Config } from '@/config';
import { snakeCase as d } from 'drizzle-orm/pg-core';

export const schema = d.schema(Config.POSTGRES_SCHEMA);
