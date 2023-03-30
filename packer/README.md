packer build -var 'vsphere_user=administrator@vsphere.local' \
             -var 'vsphere_password=password' \
             -var 'vsphere_server=address' \
             -var 'cluster=Lab' \
             -var 'datacenter=Home' \
             -var 'datastore=synology-iscsi' \
             -var 'network_name=Trusted' \
             vsphere-iso_basic_rocky9.pkr.hcl