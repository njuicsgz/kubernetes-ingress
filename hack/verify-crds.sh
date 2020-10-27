#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_ROOT=$(dirname "${BASH_SOURCE}")/..

DIFFROOT="${SCRIPT_ROOT}/deployments/common/${1}/"
TMP_DIFFROOT="${SCRIPT_ROOT}/_tmp/deployments/common/${1}/"
_tmp="${SCRIPT_ROOT}/_tmp"

cleanup() {
  rm -rf "${_tmp}"
}
trap "cleanup" EXIT SIGINT

cleanup

mkdir -p "${TMP_DIFFROOT}"
cp -a "${DIFFROOT}"/* "${TMP_DIFFROOT}"

controller-gen schemapatch:manifests=./deployments/common/${1}/ paths="./pkg/apis/configuration/..." output:dir=${TMP_DIFFROOT}
echo "diffing ${DIFFROOT} against potentially updated crds"
ret=0
diff -Naupr "${DIFFROOT}" "${TMP_DIFFROOT}" || ret=$?
if [[ $ret -eq 0 ]]
then
  echo "${DIFFROOT} up to date."
else
  echo "${DIFFROOT} is out of date. Please regenerate crds"
  exit 1
fi
