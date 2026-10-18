ARG BASE_IMAGE=teyfix/base:sha-208d7e1e9017793d5d1e7a4cc90c54a1de2f55f5
ARG BROKER_TOOLS_IMAGE=teyfix/broker-tools:sha-208d7e1e9017793d5d1e7a4cc90c54a1de2f55f5
ARG VECTOR_IMAGE=teyfix/vector:sha-208d7e1e9017793d5d1e7a4cc90c54a1de2f55f5
ARG CONNECT_IMAGE=teyfix/redpanda-connect:sha-b16a10bdf57e0a1b6db64efa43b545398039959e

FROM ${BROKER_TOOLS_IMAGE} AS brokers

FROM ${BASE_IMAGE} AS kafka-init
RUN apk add --no-cache bash jq
COPY --from=brokers /tools/bin/ /tools/bin/
WORKDIR /app
ENTRYPOINT ["/bin/bash", "/app/kafka/entrypoint.sh"]
CMD []

FROM ${VECTOR_IMAGE} AS seed
RUN apk add --no-cache jq
WORKDIR /app

FROM ${CONNECT_IMAGE} AS connect
WORKDIR /app
