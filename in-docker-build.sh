set -eux -o pipefail

apk add jq

PKG_FILENAME=$(jq -r ".versions[\"${PKG_VERSION}\"].${TARGETARCH}.filename" /pkg-info.json)
PKG_DIGEST=$(jq -r ".versions[\"${PKG_VERSION}\"].${TARGETARCH}.digest" /pkg-info.json)
PKG_DL_URL=$(jq -r ".versions[\"${PKG_VERSION}\"].${TARGETARCH}.download_url" /pkg-info.json)

PKG_ARCH_FILE=/tmp/$PKG_FILENAME

wget -O ${PKG_ARCH_FILE} $PKG_DL_URL

case $PKG_DIGEST in
  sha256:*)
    echo "${PKG_DIGEST#sha256:} ${PKG_ARCH_FILE}" | sha256sum -c -
    ;;
  sha512:*)
    echo "${PKG_DIGEST#sha512:} ${PKG_ARCH_FILE}" | sha512sum -c -
    ;;
  *)
    echo "Unsupported digest format \`$PKG_DIGEST\`" >&2
    exit 1
    ;;
esac

mkdir -p /opt/prowlarr
tar --directory=/opt/prowlarr --extract --gzip --file ${PKG_ARCH_FILE} --strip-components=1
rm -rf /opt/prowlarr/Prowlarr.Update
rm ${PKG_ARCH_FILE}
