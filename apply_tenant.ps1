# Configure the Tenant Service 
# SO this is still a work in progress

#
Write-Host "We now need to configure the initial Tenant and Client"
# Create the initial Tenant and set it in the yaml
$initTenant ="{}"
try {
    Invoke-WebRequest $env:InstallationDNSName/api/Tenants `
     -ErrorVariable $walletError1 `
     -ErrorAction SilentlyContinue `
     -Method 'POST' `
     -ContentType 'application/json; charset=utf-8' `
     -Body $initTenant 
 
     Write-Output("Tenant created successfully.")
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
   Write-Error -Message 'An Error occured creating the inital tanant.'
 }

 #Then set the setting in the YAML

 #Then Restart the Tenant Deployment