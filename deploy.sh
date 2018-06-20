#!/bin/bash

env=$1

if [ "${env}" == "" ]; then
    echo "No environment provided."
    exit 1
fi

valid="[A-Za-z0-9]"
if [[ ! ${env} =~ ${valid} ]]; then
    echo "Environment only accepts alphanumeric."
    exit 1
fi

if [ $(echo -n "${env}" | wc -c) -gt 3 ]; then
    echo "Environment name must be shorter than 3 characters."
    exit 1
fi


rsg_name="rg-tomtec-f5-tut-${env}"
deployment_name="${rsg_name}-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)"
template_file_name="arm_template.json"
parameter_file_name="parameters.json"

location_long="Australia SouthEast"

#az login > /dev/null

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

az group deployment create \
    --name "${deployment_name}" \
    --mode "incremental" \
    --resource-group "${rsg_name}" \
    --template-file "${template_file_name}" \
    --parameters @"${parameter_file_name}"

az vm run-command invoke -g "${rsg_name}" -n "vm-f5-app-${env}01" --command-id RunShellScript --scripts "git clone 'https://github.com/tomtechnologies/f5_azure_tut.git' ; cd f5_azure_tut ; bash install.sh & ; disown"


#az logout