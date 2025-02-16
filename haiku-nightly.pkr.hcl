variable "os_version" {
  type = string
  description = "The version of the operating system to download and install"
}

variable "architecture" {
  default = "amd64"
  type = string
  description = "The architecture of CPU to use when building"
}

variable "machine_type" {
  default = "pc"
  type = string
  description = "The type of machine to use when building"
}

variable "cpu_type" {
  default = "qemu64"
  type = string
  description = "The type of CPU to use when building"
}

variable "memory" {
  default = 4096
  type = number
  description = "The amount of memory to use when building the VM in megabytes"
}

variable "cpus" {
  default = 2
  type = number
  description = "The number of cpus to use when building the VM"
}

variable "disk_size" {
  default = "12G"
  type = string
  description = "The size in bytes of the hard disk of the VM"
}

variable "checksum" {
  type = string
  description = "The checksum for the virtual hard drive file"
}

variable "root_password" {
  default = "vagrant"
  type = string
  description = "The password for the root user"
}

variable "secondary_user_password" {
  default = "vagrant"
  type = string
  description = "The password for the `secondary_user_username` user"
}

variable "secondary_user_username" {
  default = "vagrant"
  type = string
  description = "The name for the secondary user"
}

variable "headless" {
  default = false
  description = "When this value is set to `true`, the machine will start without a console"
}

variable "use_default_display" {
  default = true
  type = bool
  description = "If true, do not pass a -display option to qemu, allowing it to choose the default"
}

variable "display" {
  default = "cocoa"
  description = "What QEMU -display option to use"
}

variable "accelerator" {
  default = "tcg"
  type = string
  description = "The accelerator type to use when running the VM"
}

locals {
  image_architecture = var.architecture == "x86-64" ? "x86_64" : (
    var.architecture == "x86" ? "x86_gcc2h" : var.architecture
  )
  vm_name = "haiku-${var.os_version}-${var.architecture}.qcow2"
  iso_path = "release/master/${var.os_version}/${local.image_architecture}/haiku-nightly-anyboot.iso"
  qemu_architecture = var.architecture == "x86-64" ? "x86_64" : var.architecture
}

source "qemu" "qemu" {
  machine_type = var.machine_type
  cpus = var.cpus
  memory = var.memory
  net_device = "virtio-net"

  disk_compression = true
  disk_interface = "virtio-scsi"
  disk_size = var.disk_size
  format = "qcow2"

  headless = var.headless
  use_default_display = var.use_default_display
  display = var.display
  accelerator = var.accelerator

  boot_wait = "45s"

  boot_command = [
    "<enter><wait30s>",
    "<menu><wait5s>",
    "<down><down><down><down><down><down><down><down><down><down><right><wait2s>",
    "<down><down><down><down><down><down><down><down><down><down><down><down><down><down><down><down><down><down><down><down><down><down><down><down><enter><wait5s>",
    "echo \"PermitRootLogin yes\" >> /system/settings/ssh/sshd_config<enter>",
    "passwd<enter>${var.root_password}<enter>${var.root_password}<enter>",
    "mkfs -t bfs -q /dev/disk/scsi/2/0/0/raw HaikuRunner<enter>",
    "mountvolume HaikuRunner<enter>",
    "Installer<enter><wait2s>",
    "<enter><wait3s>",
    "<tab><wait1s><tab><wait1s><down><wait1s><up><wait1s><down><wait1s><enter><wait1s><enter><wait45s>",
    "<enter><wait1s>",
    "cp /system/settings/ssh/ssh_host_* /HaikuRunner/system/settings/ssh/<enter>",
    "shutdown -r<enter>"
  ]

  ssh_username = "user"
  ssh_password = var.root_password
  ssh_timeout = "10000s"

  qemuargs = [
    ["-cpu", var.cpu_type],
    ["-monitor", "none"]
  ]

  iso_checksum = var.checksum
  iso_urls = [
  	"https://haiku.movingborders.es/testbuild/${local.iso_path}"
  ]

  http_directory = "."
  output_directory = "output"
  shutdown_command = "shutdown"
  vm_name = local.vm_name
}

build {
  sources = ["qemu.qemu"]
  
  provisioner "shell" {
    script = "resources/provision.sh"
    execute_command = "chmod +x {{ .Path }}; env {{ .Vars }} {{ .Path }}"
    environment_vars = [
      "SECONDARY_USER_USERNAME=${var.secondary_user_username}",
      "SECONDARY_USER_PASSWORD=${var.secondary_user_password}",
      "OS_VERSION=${var.os_version}"
    ]
  }

}
