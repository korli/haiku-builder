#!/bin/sh

set -exu


install_extra_packages() {
  pkgman update -y haiku haiku_devel haiku_loader haiku_datatranslators webpositive
}

install_extra_packages

