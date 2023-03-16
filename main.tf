terraform {
  required_providers {
    unifi = {
      source = "paultyng/unifi"
      version = "0.41.0"
    }
  }
}

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

locals {
  ips = csvdecode(file("${path.module}/ip_list.csv"))
  # data structure
  # ip,note
  # 192.168.1.10,pc x
}

# Create a firewall object of ip's from csv
resource "unifi_firewall_group" "plex_ips" {
  name = "plex-allowed-ip"
  type = "address-group"
  members = [ for ip in local.ips : ip.ip ]
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