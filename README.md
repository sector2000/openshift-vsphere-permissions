# openshift-vsphere-permissions


## Description

The script `setup-vcenter-permissions.sh` grants the correct permissions to the openshift technical user to perform an IPI installation on vSphere


## Requirements

* `govc`
* vSphere user with admin privileges


## Assumptions

* Precreated virtual machine folder
* Precreated resource pool
* VM folder is not root


## Usage

Set the required information in the `configuration` file.

Export:

`GOVC_URL=<vsphere API server>`

`GOVC_USERNAME=<vsphere username>`

`GOVC_PASSWORD=<vsphere password>`

`GOVC_TLS_CA_CERTS=<path to vsphere API server CA certs>` or `GOVC_INSECURE=1`

Run:
```
./setup-vcenter-permissions.sh
```


## References

* https://github.com/openshift/installer/blob/master/docs/user/vsphere/privileges.md
