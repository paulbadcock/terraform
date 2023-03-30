
variable "vsphere_server" {
  type    = string
  default = ""
}

variable "vsphere_user" {
  type    = string
  default = ""
}

variable "vsphere_password" {
  type    = string
  default = ""
}

variable "datacenter" {
  type    = string
  default = ""
}

variable "cluster" {
  type    = string
  default = ""
}

variable "datastore" {
  type    = string
  default = ""
}

variable "network_name" {
  type    = string
  default = ""
}

source "vsphere-iso" "this" {
  vcenter_server      = var.vsphere_server
  username            = var.vsphere_user
  password            = var.vsphere_password
  datacenter          = var.datacenter
  cluster             = var.cluster
  insecure_connection = true

  vm_name       = "Rocky-9.1-x86_64"
  guest_os_type = "centos64Guest"

  ssh_username = "packer"
  ssh_password = "packer"

  CPUs            = 1
  RAM             = 1024
  RAM_reserve_all = true

  disk_controller_type = ["pvscsi"]
  datastore            = var.datastore
  storage {
    disk_size             = 40960
    disk_thin_provisioned = true
  }

  iso_url = "http://download.rockylinux.org/pub/rocky/9.1/isos/x86_64/Rocky-9.1-x86_64-boot.iso"
  iso_checksum = "sha256:a36753d0efbea2f54a3dc7bfaa4dba95efe9aa3d6af331d5c5b147ea91240c21"

  network_adapters {
    network      = var.network_name
    network_card = "vmxnet3"
  }

  floppy_files = [
    "boot/ks.cfg"
  ]

  boot_command = [
    "<up><tab><bs><bs><bs><bs><bs>inst.ks=hd:fd0:/ks.cfg<enter><wait>"
  ]
}

build {
  sources = [
    "source.vsphere-iso.this"
  ]

  provisioner "shell-local" {
    inline = ["echo the address is: $PACKER_HTTP_ADDR and build name is: $PACKER_BUILD_NAME"]
  }
}

