terraform {
  required_version = ">= 0.15"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.36.2"
    }
    hetznerdns = {
      source = "timohirt/hetznerdns"
      version = "2.2.0"
    }
  }
  #backend "s3" {
  #  bucket         = "trackdirect-for-hetzner"
  #  key            = "global/s3/terraform.tfstate"
  #  region         = "eu-central-1"
  #  dynamodb_table = "trackdirect-for-hetzner"
  #  encrypt        = true
  #}
}
