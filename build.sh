#!/bin/bash

set -euxo pipefail

curl -LO https://github.com/korli/packer-plugin-qemu/releases/download/v0.0.1/packer-plugin-qemu
chmod 755 packer-plugin-qemu

OS_VERSION="$1"; shift
ARCHITECTURE="$1"; shift
HCL=haiku.pkr.hcl
VAR_VERSION=$OS_VERSION
if [[ $OS_VERSION == hrev* ]]; then
	HCL=haiku-nightly.pkr.hcl
	VAR_VERSION=nightly
fi

packer build \
  -var os_version="$OS_VERSION" \
  -var-file "var_files/common.pkrvars.hcl" \
  -var-file "var_files/$ARCHITECTURE.pkrvars.hcl" \
  -var-file "var_files/$VAR_VERSION/$ARCHITECTURE.pkrvars.hcl" \
  "$@" \
  $HCL
