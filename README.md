# terraform

Make the csv files ip_plex.csv and ip_vsphere.csv like

```csv
ip,note
192.168.99.88,
```

You need to declare a way into terraform so use the following vars of a local account in unifi

```shell
UNIFI_USERNAME=1
UNIFI_PASSWORD=2
UNIFI_API=url
UNIFI_INSECURE=true
```

To apply with the vars required

```shell
terraform apply -var="dyndns_hostname=newhost" -var="dyndns_password=token"
```

# Todo

```text
unifi_port_profile
unifi_radius_profile
unifi_setting_mgmt
unifi_setting_radius
unifi_setting_usg
unifi_site
unifi_static_route
unifi_user
unifi_user_group
unifi_wlan
```