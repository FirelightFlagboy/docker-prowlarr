# syntax=docker/dockerfile:1.4

FROM --platform=$BUILDPLATFORM alpine:3.18 as builder

COPY --link pkg_info.json /pkg_info.json

ARG PKG_VERSION
ARG TARGETARCH

RUN <<EOF
set -ex -o pipefail

apk add jq

PKG_ARCH=$(jq -r ".[\"${PKG_VERSION}\"].${TARGETARCH}.arch" /pkg_info.json)
PKG_SHA512_DIGEST=$(jq -r ".[\"${PKG_VERSION}\"].${TARGETARCH}.sha512" /pkg_info.json)

PKG_ARCH_FILE=/tmp/prowlarr.linux-musl-core.tar.gz

wget -O $PKG_ARCH_FILE https://github.com/Prowlarr/Prowlarr/releases/download/v${PKG_VERSION}/Prowlarr.master.${PKG_VERSION}.linux-musl-core-${PKG_ARCH}.tar.gz
echo "${PKG_SHA512_DIGEST} $PKG_ARCH_FILE"| sha512sum -c -
mkdir -p /opt/prowlarr
tar --directory=/opt/prowlarr --extract --gzip --file $PKG_ARCH_FILE --strip-components=1
rm -rf /opt/prowlarr/Prowlarr.Update
rm $PKG_ARCH_FILE
EOF

FROM alpine:3.18

ARG PKG_VERSION

LABEL org.opencontainers.image.source="https://github.com/Prowlarr/Prowlarr"
LABEL org.opencontainers.image.description="Prowlarr is an indexer manager/proxy built on the popular arr .net/reactjs base stack to integrate with your various PVR apps."
LABEL org.opencontainers.image.version=${PKG_VERSION}
LABEL org.opencontainers.image.title="Prowlarr"

COPY --from=builder /opt/prowlarr /opt
RUN apk --no-cache add icu-libs sqlite-libs

USER 1234:1234

ENTRYPOINT [ "/opt/prowlarr/Prowlarr", "-nobrowser", "-data=/config" ]
