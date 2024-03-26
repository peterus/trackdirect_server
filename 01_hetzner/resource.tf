provider "hcloud" {
  token = var.HCLOUD_TOKEN
}

provider "hetznerdns" {
  apitoken = var.HCLOUD_DNS_TOKEN
}

resource "hcloud_network" "network_trackdirect" {
  name     = "network_trackdirect"
  ip_range = "10.0.0.0/24"
}

resource "hcloud_network_subnet" "network_trackdirect-subnet" {
  type         = "cloud"
  network_id   = hcloud_network.network_trackdirect.id
  network_zone = "eu-central"
  ip_range     = "10.0.0.0/24"
}

resource "hcloud_primary_ip" "trackdirect_ip" {
  name          = "trackdirect_ip"
  datacenter    = data.hcloud_datacenter.nuremberg.name
  type          = "ipv4"
  assignee_type = "server"
  auto_delete   = false
}

resource "hcloud_firewall" "trackdirect_firewall" {
  name = "trackdirect_firewall"
  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  #  rule {
  #    direction = "in"
  #    protocol  = "tcp"
  #    port      = "80"
  #    source_ips = [
  #      "0.0.0.0/0",
  #      "::/0"
  #    ]
  #  }
  #
  #  rule {
  #    direction = "in"
  #    protocol  = "tcp"
  #    port      = "443"
  #    source_ips = [
  #      "0.0.0.0/0",
  #      "::/0"
  #    ]
  #  }
  #
  #  rule {
  #    direction = "in"
  #    protocol  = "tcp"
  #    port      = "9001"
  #    source_ips = [
  #      "0.0.0.0/0",
  #      "::/0"
  #    ]
  #  }
}

resource "hcloud_server" "trackdirect" {
  name         = "trackdirect"
  image        = var.os-image
  server_type  = var.server-type
  datacenter   = data.hcloud_datacenter.nuremberg.name
  ssh_keys     = [data.hcloud_ssh_key.deploy.id]
  firewall_ids = [hcloud_firewall.trackdirect_firewall.id]

  network {
    network_id = hcloud_network.network_trackdirect.id
    ip         = "10.0.0.3"
  }

  public_net {
    ipv4_enabled = true
    ipv4         = hcloud_primary_ip.trackdirect_ip.id
    ipv6_enabled = true
  }

  depends_on = [
    hcloud_network_subnet.network_trackdirect-subnet
  ]
}

resource "hcloud_managed_certificate" "trackdirect_cert" {
  name         = "trackdirect_cert"
  domain_names = ["aprs-map.info"]
}

resource "hcloud_load_balancer" "load_balancer_trackdirect" {
  name               = "trackdirect-load-balancer"
  load_balancer_type = "lb11"
  location           = "nbg1"
}

resource "hcloud_load_balancer_service" "load_balancer_service_web_https" {
  load_balancer_id = hcloud_load_balancer.load_balancer_trackdirect.id
  protocol         = "https"
  http {
    certificates  = [hcloud_managed_certificate.trackdirect_cert.id]
    redirect_http = true
  }
}

resource "hcloud_load_balancer_service" "load_balancer_service_websocket_https" {
  load_balancer_id = hcloud_load_balancer.load_balancer_trackdirect.id
  protocol         = "https"
  listen_port      = 9001
  destination_port = 9000
  http {
    certificates = [hcloud_managed_certificate.trackdirect_cert.id]
  }
}

resource "hcloud_load_balancer_target" "load_balancer_target" {
  type             = "server"
  load_balancer_id = hcloud_load_balancer.load_balancer_trackdirect.id
  server_id        = hcloud_server.trackdirect.id
  use_private_ip   = true
}

resource "hcloud_load_balancer_network" "srvnetwork" {
  load_balancer_id = hcloud_load_balancer.load_balancer_trackdirect.id
  network_id       = hcloud_network.network_trackdirect.id
  ip               = "10.0.0.2"
}


resource "hetznerdns_zone" "zone1" {
  name = "aprs-map.info"
  ttl  = 60
  lifecycle {
    prevent_destroy = true
  }
}

resource "hetznerdns_record" "testaprs" {
  zone_id = hetznerdns_zone.zone1.id
  name    = "@"
  value   = hcloud_load_balancer.load_balancer_trackdirect.ipv4
  type    = "A"
  ttl     = 60
}
