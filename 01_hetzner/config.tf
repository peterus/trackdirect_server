variable "HCLOUD_TOKEN" {
  sensitive = true
}

variable "HCLOUD_DNS_TOKEN" {
  sensitive = true
}

variable "os-image" {
  default = "ubuntu-22.04"
}

variable "server-type" {
  default = "cpx21"
}

data "hcloud_datacenter" "nuremberg" {
  name = "nbg1-dc3"
}

data "hcloud_ssh_key" "deploy" {
  name = "deploy"
}
