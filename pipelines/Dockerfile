ARG ALPINE_IMAGE="alpine:3.23"
ARG CUE_IMAGE="cuelang/cue:0.16.1"
ARG RD_CONNECT_IMAGE="redpandadata/connect:4.83.0"
ARG REDPANDA_IMAGE="redpandadata/redpanda:v25.3.10"
ARG VECTOR_IMAGE="timberio/vector:0.54.0-alpine"

FROM ${CUE_IMAGE} AS cue

FROM ${RD_CONNECT_IMAGE} AS connect

FROM ${REDPANDA_IMAGE} AS redpanda

FROM ${VECTOR_IMAGE} AS vector

FROM ${ALPINE_IMAGE} AS runtime

RUN apk add --no-cache bash rsync watchexec wget

COPY --from=connect /redpanda-connect /usr/local/bin/redpanda-connect
COPY --from=cue /bin/cue /usr/local/bin/cue
COPY --from=redpanda /opt/redpanda/libexec/rpk /usr/local/bin/rpk
COPY --from=vector /usr/local/bin/vector /usr/local/bin/vector

ENV USERNAME=pipeline
ENV APP_STAGE="/tmp/stage"
ENV APP_TARGET="/tmp/target"

RUN addgroup ${USERNAME} \
  && adduser -s /bin/bash -D -G ${USERNAME} -h /home/${USERNAME} ${USERNAME}

RUN mkdir -p /data \
  && chown -R ${USERNAME}:${USERNAME} /data

USER ${USERNAME}
WORKDIR /home/${USERNAME}

ENTRYPOINT ["/bin/bash"]
