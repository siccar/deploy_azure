# Siccar Installation Deployment for AZURE

The following procedure should help you get Siccar up and running in your own Azure Tenant.

The installation configured is suitable for test and build purposes, further refinements can and should be made for a scalable and secure deployment.

This procedure should be run using a computer with the following tooling

* Microsoft .Net 6 Framework https://dotnet.microsoft.com/en-us/download
* Azure CLI https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli 
* DAPR https://docs.dapr.io/getting-started/install-dapr-cli/
* kubectl kubernetes tooling https://kubernetes.io/docs/tasks/tools/

you should also add the following extentions to the Azure CLI

     az feature register --namespace "Microsoft.ContainerService" --name "AKS-ExtensionManager"
     az feature register --namespace "Microsoft.ContainerService" --name "AKS-Dapr"

and lastly install or restore the siccarcmd dotnet tool (currently only windows)

     dotnet tool install siccarcmd

## Steps

Documentation and tooling to deploy a Siccar installation on Microsoft Azure.

The following Azure resources should be deployed in your choosen subscription and data centre location.

* Azure Kubernetes Service - choose appropriate VM Sets/sizes
* Cosmos API For MongoDB
* Azure Database for MySQL

Once you have the ingress IP address from the AKS deployment you should add the appropriate DNS record

Within your choosen deployment environment download this tool, we currently support Powershell environments on Windows with Mac / Linux coming shortly but not currently Azure Cloud Shell until we can install DAPR tooling.

     git clone https://github.com/siccar/deploy

Follow the steps to setup up the Azure Infrastructure

### Step 1

Get your stuff together:

1. Decide and note the names for the installation i.e. n1siccardev
2. Note its fully qualified DNS domain name i.e n1.siccar.dev
3. Create your SSL Certificate and place the files in the ./certificates directory naming the files 'installationName'.crt and 'installationName'.key i.e. n1siccardev.crt  

Prepare your Active Directory

1. Create an Application in AD to host the Siccar Server  ... AzurePortal > Active Directory > App Registrations > Add
2. Set appropriate branding and properties
3. Select the 'Authentication' tab
4. Add a Single-Page platform and add the return URL to the chosen installation name as  https://{{dns_domain_name}}/signin-ad  
5. Enable both checkboxes for Access Tokens and ID Tokens
6. Select the 'Certificates & Secrets' tab
7. Create a new Client secret, giving it a suitable description, store the secret value string for use later in KeyVault setup.

Make sure you have logged into your Azure Command shell and correct subscription:

     az login
     az account set --subscription "mySubscriptionName"


### Step 2

Run the initialize powershell command, this will ask for the basic setup properties:

* Installation Name i.e. n1siccardev
* Installation DNS Name as is used with for SSL Certificate, which will be installed later
* Resource Group to install into  i.e. n1siccardev
* A required PAT Token for access to the Deployment ACR is required i.e. hlaquoruwmp25rd...nhhdltprvvobzwujts3q this can be internally generated and time limted

You can now start with:

     ./initializeSiccar.ps1 <resource_group> <installation_name> <domain_name> <location> <pat>

This should have setup the basics and fetched the runtime images, we now need to setup the Tenant Service.

Specifically steps accomplished:

* Set some temporary environment variables
* Installed Dapr to the cluster
* Created and attached a Container Registry
* Copied the service runtime images
* Created the services
* Provided Dapr connectivity
* Created a shared disk for persistent storage
* Create and publishes an Azure Service Bus
* Processed the source YAML for customized deployment

### Step 3

Its time to deploy the Connection Strings as Kubernetes Secrets, you will be asked for the following information:

* MongoDB Connection String : Can be retrieved from the Azure Portal UI under the DB Settings > ConnectionStrings
* MYSQL Connection String : Again retrieved from the Azure Portal

!! Check your SSL Certificate is in the ./certificates directory

It can be applied on the command line or will prompt for the values

     ./apply_connections.ps1

### Step 4

Configuring inbound access via ingress-nginx, with SSL

     ./apply_proxy.ps1

### Step 5

Configure the Azure Key Vault Service for Wallet Protection, first you must create the Azure KeyVault resource in your resource group and then create an actual valut instance within the service.

#### Azure Keyvault Service

Using the Web Azure Portal create a KeyVault Serive in you Resource Group and chosen location.

#### Azure Keyvault Connection String

 To create a keyvault instance use

     az keyvault key create --name MyKey --vault-name MyVault

 The connection string is provided as the 'kid' in the output json from the command above.

 This URI is the path to created keyvault i.e. https://keyvault_name.vault.azure.net/_path_to_keyVault

 Further you may need to configure an access policy for the App identity to access to the keyvault

     az keyvault set-policy -n MyVault --object-id <application_id> --key-permissions get unwrapKey wrapKey

#### Authentication principal

* Application ClientID, the guid of teh registered AD Application
* Application Secret, the secret created in the app authentication setup stage
* Infrastructure Tenant ID - the directory of the Managed Service Identity
* An Encryption string for DB Protection : future removal

     ./apply_keyvault.ps1

#### Ensure configuration of the MySQL store

Applied as a connection string in the apply_connections.ps1 this is configured to use a stored kuberenetes secret for the actual connection string and the deployment-microservice-wallet.yaml references this secret. If it needs changed the updated the secret by deleteing and readding using kubectl i.e.

     kubectl create secret generic walletrepository --from-literal=repo="Server=srv.mysql.database.azure.com;UserID=user;Password=####;Database=Wallets" -n default

### Step 6

Start the services

     ./start_services.ps1

### Step 7

At this point we should have a running, if not fully configured installation.

Check logs of services to ensure they start cleanly.

The following kubernetes secrets should be in place (kubectl get secrets)

* aks-ingress-tls : inbound ssl certificate
* app-api-token : DAPR Authentication token
* daprsecret : JWT Presentation of token
* local-secret-store : contains settings for Wallet.Service to access Az Key Vault
* pubsubsecret : Azure service bus connection
* registeryrepository : connection string to mongo database
* tenantrepository : connection string to tenant repository
* walletrepository : connection string to wallet SQL repository

### Step 8

Now fixup the Tenant-Service, we need to seed the Database with a default tenant and copy the SSL Certificate into the Tenant Service

* Create and embed SSL certificate in Tenant/Identity Server - copy into persistent volume and update yaml paths
* Configure and Initialise database

!! WARNING still in development

     ./apply_tenant.ps1

### Validate the Service

There a number of quick checks you can perform to ensure the service is operationally up at this point:

* Hit the https://{{dns_name}} and you should be retunred 'ok'
* Hit https://{{dns_name}}}/.well-known/openid-configuration and you should get returned the Identity metadata, ensure the issuer names are corrent.
* Hit https://{{dns_name}}}}/odata/registers/$metadata and you should be returned the Register Service OData definition

 To test the service is fully commisioned run the pingpong test, this may require some initial configuration to grant the correct access roles to the user.

## Updating

The release notes will detail any specific change in the services, there are a few common practices here:

To update the installation ACR with the latest runtime images using the 'installer' id and time limited PAT token

     .\copy_dev_acr.ps1 {{your_acr_name}} {{installed_id}} {{installer_PAT}}

## Troubleshooting and other useful stuff

kubectl is your friend

     kubectl 
          get pods 
          describe pod <pod-instance-name>
          logs -f <pod-instance-name>
          exec –tty –stdin <deployment-name> -- /bin/bash
          rollout restart deployment/<deployment-name>
     use: -A to show all name spaces

Checking your environment variables; look for InstallationName, ResourceGroup, ResourceLocation

     dir env:

Looking at pod status:

     kubectl get pods
     kubectl describe pod <pod_name>

If AKS cannot pull images from the ACR

      az aks update -n <installation_name> -g <resource_group> --attach-acr <installation_name>cr ## <- watch the CR not _acr_

Examine the state of DAPR, should open a Browser windows to localhost:8888

     dapr dashboard -k -p 8888

There might be limits on resources that cause failure in service start up e.g.

     2022-07-06T16:11:46.1945068+00:00 [FTL][/TenantService/Microsoft.AspNetCore.Hosting.Diagnostics] 
     Application startup exception MongoDB.Driver.MongoCommandException: 
     Command insert failed: Error=2, 
     Details='Response status code does not indicate success: BadRequest (400); Substatus: 1028; ActivityId: 44e636f4-c9f1-43e2-adc1-d000d63c9d72; 
     Reason: (Message: {"Errors":["Your account is currently configured with a total throughput limit of 1000 RU\/s. This operation failed because 
     it would have increased the total throughput to 1200 RU/s. See https://aka.ms/cosmos-tp-limit for more information."]} 
     ActivityId: 44e636f4-c9f1-43e2-adc1-d000d63c9d72, Request URI: /apps/0f51e5f9-98a7-4588-b5eb-e03ac99a111d/services/b3eb2825-ea1b-4b94-8b0d-1abd16dee33e/partitions/4021a20b-4a4e-47f0-8095-046ffc988c35/replicas/133005852124662274p,
     RequestStats: , SDK: Microsoft.Azure.Documents.Common/2.14.0, Microsoft.Azure.Cosmos.Tracing.TraceData.ClientSideRequestStatisticsTraceDatum, Windows/10.0.19041 cosmos-netstandard-sdk/3.18.0);.

For proxy and connectivity issues these commadns are usefull:

     kubectl describe ingress -n default
