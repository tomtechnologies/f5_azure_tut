# f5_azure_tut

F5 Azure template and Application for instruction on F5 VE

## Requires
- Bash environment
- Azure CLI installed
- jq installed
- Software terms accepted in subscription
- Logged in to target subscription


### Steps

#### Install Azure CLI + JQ
```Bash
pip install azure-cli --upgrade
yum install jq || apt-get install jq
```

#### Accept F5 license terms
This only needs to be performed once in a subscription

```PowerShell
AzureRM-SelectSubscription
Select-AzureRMSubscription -Subscription <subscription id>

$t = Get-AzureRmMarketplaceTerms -Publisher f5-networks -Product f5-big-ip-best -Name f5-bigip-virtual-edition-25m-best-hourly
Set-AzureRmMarketplaceTerms -Publisher f5-networks -Product f5-big-ip-best -Name f5-bigip-virtual-edition-25m-best-hourly -Accept -Terms $t
```

#### Login to subscription
```Bash
az login --tenant <tenant id> # Tenant ID only required if you have an account with multiple tenancies
az account set --subscription <subscription id>
```

## Deploy

### Configure
Edit `azure/parameters.json`

Change Parameters:

`env` - Alphanumberic 1-6 characters.
`vm_os_user` - Login user for your VM's.
`vm_os_password` - This is your admin password for your VM's. Note that your F5 is going to have a public IP so you probably want this somewhat secure.

Run build
```
./build.sh
```

You can connnect to your vm on the public IP

`ssh <username>@f5-tut-<env>.<region>.cloudapp.azure.com`

eg:
`ssh tomtec@f5-tut-tom.azuresoutheast.cloudapp.azure.com`