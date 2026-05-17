ARG ALPINE_IMAGE="alpine:3.23"
ARG GOMPLATE_IMAGE="hairyhenderson/gomplate:v5.0-alpine"
ARG RD_CONNECT_IMAGE="redpandadata/connect:4.83.0"
ARG REDPANDA_IMAGE="redpandadata/redpanda:v25.3.10"
ARG VECTOR_IMAGE="timberio/vector:0.54.0-alpine"

FROM ${GOMPLATE_IMAGE} AS gomplate

FROM ${RD_CONNECT_IMAGE} AS connect

FROM ${REDPANDA_IMAGE} AS redpanda

FROM ${VECTOR_IMAGE} AS vector

FROM ${ALPINE_IMAGE} AS runtime

RUN apk add --no-cache jq yq bash curl wget rsync inotify-tools

COPY --from=connect /redpanda-connect /usr/local/bin/redpanda-connect
COPY --from=gomplate /bin/gomplate /usr/local/bin/gomplate
COPY --from=redpanda /opt/redpanda/libexec/rpk /usr/local/bin/rpk
COPY --from=vector /usr/local/bin/vector /usr/local/bin/vector

ENV USERNAME=pipeline

RUN addgroup ${USERNAME} \
  && adduser -s /bin/bash -D -G ${USERNAME} -h /home/${USERNAME} ${USERNAME}

RUN mkdir -p /data \
  && chown -R ${USERNAME}:${USERNAME} /data

USER ${USERNAME}
WORKDIR /home/${USERNAME}

ENTRYPOINT ["/bin/bash"]
