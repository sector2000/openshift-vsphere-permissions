#!/bin/bash

set -e

current_dir=$(dirname $(readlink -f $0))

# Load configuration file
. ${current_dir}/configuration


# Load permission files
vcenter_permissions_file=${current_dir}/vcenter_permissions.lst
cluster_permissions_file=${current_dir}/cluster_permissions.lst
resourcepool_permissions_file=${current_dir}/resourcepool_permissions.lst
datastore_permissions_file=${current_dir}/datastore_permissions.lst
portgroup_permissions_file=${current_dir}/portgroup_permissions.lst
vmfolder_permissions_file=${current_dir}/vmfolder_permissions.lst


declare -A roles 

# Map permissions to openshift-vcenter role
vcenter_permissions=$(cat ${vcenter_permissions_file})
vcenter_role_name="openshift-vcenter-level"
roles+=( ["${vcenter_role_name}"]=${vcenter_permissions} )

# Map permissions to openshift-resourcepool role
resourcepool_permissions=$(cat ${resourcepool_permissions_file})
resourcepool_role_name="openshift-resourcepool-level"
roles+=( ["${resourcepool_role_name}"]=${resourcepool_permissions} )

# Map permissions to openshift-datastore role
datastore_permissions=$(cat ${datastore_permissions_file})
datastore_role_name="openshift-datastore-level"
roles+=( ["${datastore_role_name}"]=${datastore_permissions} )

# Map permissions to openshift-portgroup role
portgroup_permissions=$(cat ${portgroup_permissions_file})
portgroup_role_name="openshift-portgroup-level"
roles+=( ["${portgroup_role_name}"]=${portgroup_permissions} )

# Map permissions to openshift-folder role
vmfolder_permissions=$(cat ${vmfolder_permissions_file})
vmfolder_role_name="openshift-folder-level"
roles+=( ["${vmfolder_role_name}"]=${vmfolder_permissions} )

# Create roles
for key in "${!roles[@]}"; do
  if ! govc role.ls "${key}" >/dev/null 2>&1; then
    echo "Creating role ${key}..."
    govc role.create ${key} ${roles[${key}]}
    echo "Role ${key} created successfully"
    echo ""
  fi
done

# Grant roles to user
echo "Assigning roles to ${openshift_user} user..."

govc permissions.set -propagate=false -principal ${openshift_user} -role ${vcenter_role_name} /
govc permissions.set -propagate=false -principal ${openshift_user} -role ReadOnly "/${datacenter}"
govc permissions.set -propagate=true -principal ${openshift_user} -role ReadOnly "/${datacenter}/host/${cluster}"
govc permissions.set -propagate=false -principal ${openshift_user} -role ${datastore_role_name} "/${datacenter}/datastore/${datastore}"
govc permissions.set -propagate=false -principal ${openshift_user} -role ReadOnly "/${datacenter}/network/${switch}"
govc permissions.set -propagate=false -principal ${openshift_user} -role ${portgroup_role_name} "/${datacenter}/network/${network}"
govc permissions.set -propagate=true  -principal ${openshift_user} -role ${vmfolder_role_name} "/${datacenter}/vm/${vmfolder}"
govc permissions.set -propagate=true  -principal ${openshift_user} -role ${resourcepool_role_name} "/${datacenter}/host/${cluster}/Resources/${resourcepool}"

echo "Roles assigned successfully to user ${openshift_user}"
