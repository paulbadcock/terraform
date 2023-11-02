terraform {
  required_providers {
    unifi = {
      source = "paultyng/unifi"
      version = "0.41.0"
    }
  }
}

#module "vm" {
#  source  = "Terraform-VMWare-Modules/vm/vsphere"
#  version = "3.5.0"
  # insert the 50 required variables here
#}

provider "unifi" {
  # username = var.username # optionally use UNIFI_USERNAME env var
  # password = var.password # optionally use UNIFI_PASSWORD env var
  # api_url  = var.api_url  # optionally use UNIFI_API env var

  # you may need to allow insecure TLS communications unless you have configured
  # certificates for your controller
  # allow_insecure = var.insecure # optionally use UNIFI_INSECURE env var

  # if you are not configuring the default site, you can change the site
  # site = "foo" or optionally use UNIFI_SITE env var
}

#provider "vsphere" {
  #user           = "fill"
  #password       = "fill"
  #vsphere_server = "fill"

  # if you have a self-signed cert
#  allow_unverified_ssl = true
#}

locals {
  plex_ips = csvdecode(file("${path.module}/ip_plex.csv"))
  vsphere_ips = csvdecode(file("${path.module}/ip_vsphere.csv"))
}

# Create a firewall object of ip's from csv
resource "unifi_firewall_group" "plex_ips" {
  name = "plex-allowed-ip"
  type = "address-group"
  members = [ for ip in local.plex_ips : ip.ip ]
}

# Create a port group for the possible plex ports
resource "unifi_firewall_group" "plex_port" {
  name = "plex ports"
  type = "port-group"

  members = ["32400"]
}

# Create a firewall rule to allow the ips to the plex port
resource "unifi_firewall_rule" "plex_allow" {
  name    = "Plex IP Allow List"
  action  = "accept"
  ruleset = "WAN_IN"

  rule_index = 2011

  protocol = "tcp"
  logging = true

  dst_firewall_group_ids = ["${unifi_firewall_group.plex_port.id}"]
  src_firewall_group_ids = ["${unifi_firewall_group.plex_ips.id}"]
}

# block everything else to plex port on wan
resource "unifi_firewall_rule" "plex_deny" {
  name    = "Plex Deny All"
  action  = "reject"
  ruleset = "WAN_IN"

  rule_index = 2012

  protocol = "tcp"

  dst_firewall_group_ids = ["${unifi_firewall_group.plex_port.id}"]
}

resource "unifi_firewall_rule" "vmware_deny" {
  name    = "Drop VM traffic"
  action  = "reject"
  ruleset = "WAN_OUT"

  rule_index = 2000

  protocol = "all"

  src_firewall_group_ids = ["${unifi_firewall_group.vsphere.id}"]

}

resource "unifi_firewall_group" "vsphere" {
  name = "vSphere"
  type = "address-group"

  members = [ for ip in local.vsphere_ips : ip.ip ]
}

resource "unifi_dynamic_dns" "home" {
  service = "dyndns"

  host_name = var.dyndns_hostname

  server   = "www.duckdns.org"
  login    = "nouser"
  password = var.dyndns_password
}

resource "unifi_network" "default" {
  name          = "Default"
  purpose       = "corporate"

  domain_name   = "localdomain"
  subnet        = "192.168.1.1/24"
  vlan_id       = 0
  dhcp_start    = "192.168.1.6"
  dhcp_stop     = "192.168.1.254"
  dhcp_enabled  = true
  dhcp_dns      = var.upstream_dns
  dhcp_v6_start = "::2"
  dhcp_v6_stop  = "::7d1"
  ipv6_pd_start = "::2"
  ipv6_pd_stop  = "::7d1"
  ipv6_ra_enable = "true"
  ipv6_ra_priority = "high"
  ipv6_ra_valid_lifetime = 0
}

resource "unifi_network" "upnp" {
  name    = "upnp"
  purpose = "corporate"

  subnet       = "192.168.10.1/24"
  vlan_id      = 10
  dhcp_start   = "192.168.10.6"
  dhcp_stop    = "192.168.10.254"
  dhcp_enabled = true
  dhcp_dns      = var.upstream_dns
  dhcp_v6_start = "::2"
  dhcp_v6_stop  = "::7d1"
  ipv6_pd_start = "::2"
  ipv6_pd_stop  = "::7d1"
  ipv6_ra_enable = "true"
  ipv6_ra_priority = "high"
  ipv6_ra_valid_lifetime = 0
}

resource "unifi_network" "vmware" {
  name    = "vmware"
  purpose = "corporate"

  domain_name   = "local"
  subnet       = "192.168.20.1/24"
  vlan_id      = 20
  dhcp_start   = "192.168.20.6"
  dhcp_stop    = "192.168.20.254"
  dhcp_enabled = true
  dhcp_dns      = var.upstream_dns
  dhcp_v6_start = "::2"
  dhcp_v6_stop  = "::7d1"
  ipv6_pd_start = "::2"
  ipv6_pd_stop  = "::7d1"
  ipv6_ra_enable = "true"
  ipv6_ra_priority = "high"
  ipv6_ra_valid_lifetime = 0
}

resource "unifi_port_forward" "plex" {
  name = "Plex"
  dst_port = 32400
  fwd_ip = var.core_server
  fwd_port = 32400
  port_forward_interface = "both"
  protocol = "tcp"
}

resource "unifi_port_forward" "traefik_http" {
  name = "Traefik HTTP"
  dst_port = 80
  fwd_ip = var.core_server
  fwd_port = 9081
  port_forward_interface = "both"
  protocol = "tcp"
  log = "true"
}

resource "unifi_port_forward" "traefik_https" {
  name = "Traefik HTTPS"
  dst_port = 443
  fwd_ip = var.core_server
  fwd_port = 9082
  port_forward_interface = "both"
  protocol = "tcp"
  log = "true"
}