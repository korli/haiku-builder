#!/bin/sh

set -exu


setup_secondary_user() {
  useradd -d /boot/"$SECONDARY_USER_USERNAME" -s "$SHELL" "$SECONDARY_USER_USERNAME"
  mkdir -p /boot/"$SECONDARY_USER_USERNAME"
  chown "$SECONDARY_USER_USERNAME" /boot/"$SECONDARY_USER_USERNAME"
}

configure_boot_scripts() {
  local rc_dir=$HOME/config/settings/boot/launch
  local script="$rc_dir/install_authorized_keys.sh"

  mkdir -p "$rc_dir"

  cat <<EOF >> "$script"
#!/bin/bash

RESOURCES_MOUNT_PATH='/no name'

install_authorized_keys() {
  SSH_DIR="/boot/${SECONDARY_USER_USERNAME}/config/settings/ssh"
  if [ -s "\$RESOURCES_MOUNT_PATH/keys" ]; then
    mkdir -p "\$SSH_DIR"
    cp "\$RESOURCES_MOUNT_PATH/keys" "\$SSH_DIR/authorized_keys"
    chmod 600 "\$SSH_DIR/authorized_keys"
    chown -R "${SECONDARY_USER_USERNAME}:root" "/boot/${SECONDARY_USER_USERNAME}/config"
  fi
}

mountvolume -alldos
ln -s /boot /home
install_authorized_keys
EOF

  chmod +x "$script"
}


install_extra_packages() {
  if [[ "`uname -m`" == "BePC" ]]; then
	  pkgman update -y haiku haiku_devel haiku_loader haiku_datatranslators
	  pkgman update -y haiku_x86 haiku_x86_devel webpositive_x86
  else
	  pkgman update -y haiku haiku_devel haiku_loader haiku_datatranslators webpositive
  fi
}

setup_secondary_user
configure_boot_scripts
install_extra_packages

