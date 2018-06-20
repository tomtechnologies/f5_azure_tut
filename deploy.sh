#!/bin/bash
template_file_name="azure/arm_template.json"
parameter_file_name="azure/parameters.json"
location_long="Australia SouthEast"

env=$(cat ${parameter_file_name}  | jq '.parameters.env.value' | sed 's/"//g')

if [ "${env}" == "" ]; then
    echo "No environment provided."
    exit 1
fi

valid="[A-Za-z0-9]"
if [[ ! ${env} =~ ${valid} ]]; then
    echo "Environment only accepts alphanumeric."
    exit 1
fi

if [ $(echo -n "${env}" | wc -c) -gt 6 ]; then
    echo "Environment name must be shorter than 6 characters."
    exit 1
fi

rsg_name="rg-tomtec-f5-tut-${env}"
deployment_name="${rsg_name}-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)"

if [ "$1" == "delete-rg" ]; then
    az group delete --name "${rsg_name}" --yes
    exit 0
fi

ret=$(az group show --name "${rsg_name}" | wc -l)
if [ $ret -ne 0 ]; then
    echo "Azure group ${rsg_name} exists; skipping creation."
else
    echo "Azure group ${rsg_name} needs creating."
    az group create --name "${rsg_name}" --location "${location_long}"
    if [ $? -ne 0 ]; then
        exit 1
    fi
fi

# Do deployment
az group deployment create \
    --name "${deployment_name}" \
    --mode "incremental" \
    --resource-group "${rsg_name}" \
    --template-file "${template_file_name}" \
    --parameters @"${parameter_file_name}" > deployment.json

# Run install on F5 VM. TODO: > 9 count
END=$(cat ${template_file_name} | jq '.variables.f5_vm_count')
for ((i=1;i<=END;i++))
do
    az vm run-command invoke -g "${rsg_name}" -n "f5-tut-${env}0${i}" --command-id RunShellScript --scripts "sudo yum -y install git ; git clone 'https://github.com/tomtechnologies/f5_azure_tut.git' ; cd f5_azure_tut/f5 ; sudo bash install.sh"
done

# Run install on App VM. TODO: > 9 count
END=$(cat ${template_file_name} | jq '.variables.app_vm_count')
for ((i=1;i<=END;i++))
do
    az vm run-command invoke -g "${rsg_name}" -n "f5-app-${env}0${i}" --command-id RunShellScript --scripts "sudo yum -y install git ; git clone 'https://github.com/tomtechnologies/f5_azure_tut.git' ; cd f5_azure_tut/app ; sudo bash install.sh"
done
