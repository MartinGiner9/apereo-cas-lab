#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${ROOT_DIR}/cas-server/overlay"
CAS_VERSION="${CAS_VERSION:-8.0.1.2}"
INITIALIZR_URL="${CAS_INITIALIZR_URL:-https://getcas.apereo.org/starter.tgz}"

for command in curl tar; do
  if ! command -v "${command}" >/dev/null 2>&1; then
    echo "ERROR: '${command}' is required." >&2
    exit 1
  fi
done

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

mkdir -p "${TARGET_DIR}"

# Keep the tracked placeholder while replacing any previously generated overlay.
find "${TARGET_DIR}" -mindepth 1 ! -name '.gitkeep' -exec rm -rf {} +

echo "Generating Apereo CAS ${CAS_VERSION} overlay from ${INITIALIZR_URL}..."

curl --fail --show-error --silent --location \
  --request POST \
  --data-urlencode "type=cas-overlay" \
  --data-urlencode "baseDir=overlay" \
  --data-urlencode "casVersion=${CAS_VERSION}" \
  "${INITIALIZR_URL}" \
  | tar -xz -C "${TMP_DIR}"

GENERATED_DIR="${TMP_DIR}/overlay"

if [[ ! -f "${GENERATED_DIR}/gradlew" || ! -f "${GENERATED_DIR}/gradle.properties" ]]; then
  echo "ERROR: CAS Initializr did not return the expected overlay structure." >&2
  exit 1
fi

cp -a "${GENERATED_DIR}/." "${TARGET_DIR}/"
touch "${TARGET_DIR}/.gitkeep"
chmod +x "${TARGET_DIR}/gradlew" || true

echo
printf 'CAS overlay generated at: %s\n' "${TARGET_DIR}"
printf 'CAS version: %s\n' "${CAS_VERSION}"
echo
cat <<'EOF'
The overlay is generated and intentionally ignored by Git.
Project-owned CAS configuration lives in cas-server/config and cas-server/services.

When building the overlay, the lab modules will be supplied dynamically:
  - jdbc
  - json-service-registry
  - org.postgresql:postgresql
EOF
