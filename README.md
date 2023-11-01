# terraform

Make the csv files ip_plex.csv and ip_vsphere.csv like

```csv
ip,note
192.168.99.88,
```

You need to declare a way into terraform so use the following vars of a local account in unifi

```shell
UNIFI_USERNAME env var
UNIFI_PASSWORD env var
UNIFI_API
UNIFI_INSECURE = true
```
