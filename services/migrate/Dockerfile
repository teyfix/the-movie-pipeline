ARG BUN_IMAGE=oven/bun:1.3-alpine

FROM $BUN_IMAGE AS base

WORKDIR /app

FROM base AS deps

COPY ./app/package.json ./app/bun.lock ./
RUN --mount=type=cache,id=bun-cache,target=/root/.bun/install/cache \
  bun install

FROM base AS runtime

COPY --from=deps /app/node_modules ./node_modules
COPY ./app ./
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
USER root
ENTRYPOINT [ "/entrypoint.sh" ]
