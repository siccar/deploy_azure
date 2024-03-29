# Configure the Tenant Service 
# SO this is still a work in progress

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, HelpMessage="Azure AD Tenant ID")] [string] $azadtenantid='guid',
    [Parameter(Mandatory=$true, HelpMessage="Azure Application Client ID")] [string] $azadclientid='guid',
    [Parameter(Mandatory=$true, HelpMessage="Administrators Email Address")] [string] $adminemail='admin@email.com',
    [Parameter(Mandatory=$true, HelpMessage="installation name")] [string] $tenantissuer='n0.siccar.dev'
    )

#
Write-Host "We now need to configure the initial Tenant and Client"
# Create the initial Tenant and set it in the yaml

# Client ID 53cb40d8-edef-47b9-8836-f2162fcf3e62 APPCLIENTID
# Az AD Tenant ID a2b9ca5b-54e5-437e-866e-bd48bfa6159a APPTENANTID

(Get-Content ./sourceyaml/initial-clients.json) | `
    ForEach-Object { $_.replace("{{APPTENANTID}}", "$azadtenantid").
        replace("{{APPCLIENTID}}", "$azadclientid").
        replace("{{TENANTISSUER}}", "$tenantissuer").
        replace("{{EMAILID}}","$adminemail") `
    } | `
    Out-File ./components/tenant_boot.json

$initTenant = Get-Content ./components/tenant_boot.json
$defaultTenant = "_"

try {
    $defaultTenant = (Invoke-WebRequest $env:InstallationDNSName/api/init `
     -ErrorVariable $walletError1 `
     -ErrorAction SilentlyContinue `
     -Method 'POST' `
     -ContentType 'application/json; charset=utf-8' `
     -Body $initTenant `
     | `
     Select-Object -Property Content).Content
    # need to extract the response content and use that as the 

     Write-Output("Tenant created successfully. ID : $defaultTenant")
 }
 catch [Microsoft.PowerShell.Commands.HttpResponseException] {
   if ($_.ErrorDetails -like "*400*") {
     Write-Warning -Message 'Tenant already exists.'
   }
   else {
     Write-Host $_
     Write-Error -Message 'Siccar platform returned error http response' 
   }
 
 }
 catch {
   Write-Host $_
   Write-Error -Message 'An Error occured creating the inital tenant.'
 }

 #Then set the default tenant setting in the YAML
 (Get-Content ./deployments/deployment-microservice-tenant.yaml) | `
  ForEach-Object { $_.replace("{{DEFAULTTENANT}}", "$defaultTenant") `
 } | `
 Out-File ./deployments/deployment-microservice-tenant.yaml

 #Then Restart the Tenant Deployment
 kubectl delete deployment tenant-service
 kubectl apply -f ./deployments/deployment-microservice-tenant.yaml