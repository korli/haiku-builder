#!/bin/bash

set -euxo pipefail

curl -LO https://github.com/korli/packer-plugin-qemu/releases/download/v0.0.1/packer-plugin-qemu
chmod 755 packer-plugin-qemu

OS_VERSION="$1"; shift
ARCHITECTURE="$1"; shift

packer build \
  -var os_version="$OS_VERSION" \
  -var-file "var_files/common.pkrvars.hcl" \
  -var-file "var_files/$ARCHITECTURE.pkrvars.hcl" \
  -var-file "var_files/$OS_VERSION/$ARCHITECTURE.pkrvars.hcl" \
  "$@" \
  haiku.pkr.hcl
