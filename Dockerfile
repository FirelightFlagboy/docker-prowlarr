# syntax=docker/dockerfile:1.4

FROM --platform=$BUILDPLATFORM alpine:3.19 as builder

COPY --link pkg-info.json /pkg-info.json

ARG PKG_VERSION
ARG TARGETARCH

COPY --link in-docker-build.sh /build.sh

RUN sh /build.sh

FROM alpine:3.19

ARG PKG_VERSION

LABEL org.opencontainers.image.source="https://github.com/Prowlarr/Prowlarr"
LABEL org.opencontainers.image.description="Prowlarr is an indexer manager/proxy built on the popular arr .net/reactjs base stack to integrate with your various PVR apps."
LABEL org.opencontainers.image.version=${PKG_VERSION}
LABEL org.opencontainers.image.title="Prowlarr"

COPY --from=builder /opt/prowlarr /opt/prowlarr
RUN apk --no-cache add icu-libs sqlite-libs

USER 1234:1234

ENTRYPOINT [ "/opt/prowlarr/Prowlarr", "-nobrowser", "-data=/config" ]
