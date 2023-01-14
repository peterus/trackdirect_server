output "trackdirect" {
  value = tomap({
    (hcloud_server.trackdirect.name) = hcloud_server.trackdirect.ipv4_address
  })
  sensitive = true
}

output "ssh-public-key" {
  value = data.hcloud_ssh_key.deploy.public_key
  sensitive = true
}
