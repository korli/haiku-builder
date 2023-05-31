#!/bin/sh

set -exu


install_extra_packages() {
  if [[ "`uname -m`" == "BePC" ]]; then
	  pkgman update -y haiku haiku_devel haiku_loader haiku_datatranslators
	  pkgman update -y haiku_x86 haiku_x86_devel webpositive_x86
  else
	  pkgman update -y haiku haiku_devel haiku_loader haiku_datatranslators webpositive
  fi
}

install_extra_packages

