ARG BUN_IMAGE=oven/bun:1.3-alpine

FROM ${BUN_IMAGE} AS base

FROM base AS builder
WORKDIR /usr/src/app
RUN echo '{}' >> package.json

FROM base AS runtime
RUN apk add --no-cache \
  bash \
  jq \
  kcat \
  parallel

RUN wget -O /usr/local/bin/jaq "https://github.com/01mf02/jaq/releases/latest/download/jaq-x86_64-unknown-linux-musl" \
  && chmod +x /usr/local/bin/jaq


ENV PARALLEL="--no-notice"
WORKDIR /usr/src/app

RUN echo '{}' > package.json \
  && bun add --production prettier@3.8.3 quicktype@23.2.6

VOLUME [ "/sample" ]
