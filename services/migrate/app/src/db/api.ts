import { TNull, TOptional, TSchema, TUnion, Type } from '@sinclair/typebox';

export * as d from 'drizzle-orm/pg-core';

export const t = Object.assign({}, Type, {
  Nullish<T extends TSchema>(T: T): TOptional<TUnion<[T, TNull]>> {
    return t.Optional(t.Nullable(T));
  },
  Nullable<T extends TSchema>(T: T): TUnion<[T, TNull]> {
    return t.Union([T, t.Null()]);
  },
});
