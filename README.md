# Siccar Installation Deployment for AZURE

The following procedure should help you get Siccar up and running in your own Azure Tenant.

The installation configured is suitable for test and build purposes, further refinements can and should be made for a scalable and secure deployment.

This procedure should be run using a computer with the following tooling

* Microsoft .Net 6 Framework <https://dotnet.microsoft.com/en-us/download>
* Powershell <https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell>
* Azure CLI <https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli>
* DAPR <https://docs.dapr.io/getting-started/install-dapr-cli/>
* kubectl kubernetes tooling <https://kubernetes.io/docs/tasks/tools/>

you should also add the following extentions to the Azure CLI

     az feature register --namespace "Microsoft.ContainerService" --name "AKS-ExtensionManager"
     az feature register --namespace "Microsoft.ContainerService" --name "AKS-Dapr"

and lastly install or restore the siccarcmd dotnet tool

     dotnet tool install siccarcmd

IMPORTANAT NOTES:

* This is an early release some scripts can still be a bit brittle!
* while the tooling runs across all platforms the DAPR installation tool cannot be used from Cloud Shell therefore do not perform the installation from Cloud Shell
* The scripts in part use environment variables for certain settings, these can be reset with ./set_installation.ps1
* Try to complete the commisioning in a single shell environment

## Steps

Documentation and tooling to deploy a Siccar installation on Microsoft Azure.

Follow the steps to setup up the Azure Infrastructure

### Step 1 - Preparation

1. Decide and note the names for the installation, could be a project or concatination of the node name

* {{ResourceGroup}} i.e. n1siccardev
* {{InstallationName}} i.e. n1siccardev
* {{ResourceLocation}} i.e. uksouth
* {{DNSName}} i.e. n1.siccar.dev

2. Create a directory for the deployment configuration and clone the toolkit into it

     mkdir {{InstallationName}}
     git clone <https://github.com/siccar/deploy> {{InstallationName}}
     cd {{InstallationName}}


3. Create your SSL Certificate and place the files in the ./certificates directory naming the files {{InstallationName}}.crt and {{InstallationName}}.key i.e. n1siccardev.crt  

#### Prepare your Active Directory for the Siccar Installation

We need to create two application entities in Active Directory, the first is an for the installation itself to gain access to infrastructure services. The second is for the front end administrative and user application authentication and its configuration will affect the user login processes.

{{SiccarV3Tenant}} is the Azure Active Directory Tenant GUId i.e. a2b9ca...

1. Create an Application in AD to host the Siccar Server  ... AzurePortal > Active Directory > App Registrations > Add ; Call the first infrastructure 'SiccarV3 and the second 'SiccarAdmin'
2. Set appropriate branding and properties
3. Select the 'Authentication' tab
4. For the 'SiccarAdmin' Overview Client ID is GUID {{SiccarAppID}} i.e. 53cb40...
4.1 Add a Single-Page platform and add the return URL to the chosen installation name as  'https://{{DNS_Name}}/signin-ad'  
4.2 Enable both checkboxes for Access Tokens and ID Tokens
5. For 'SiccarV3' GUID {{SiccarV3Id}}
5.1 Select the 'Certificates & Secrets' tab
5.2 Create a new Client secret, giving it a suitable description, store the secret value string for use later in KeyVault setup.

The following Azure resources should be deployed in your choosen subscription and data centre location.
Name of each of these should match the resource group and deployment name i.e. n1siccardev

* A Resource group name {{InstallationName}}
* Azure Kubernetes Service - choose appropriate VM Sets/sizes
* Cosmos API For MongoDB
* Azure Database for MySQL, ensure under networking that 'Allow public access from any Azure service' in Enabled

The creation of the Azure Kubernetes service will also create a secondary resource group that contains the infrastructure and servers hosting the Kubernetes instance, its likely called MC_{{ResourceGroup}}_{{InstallationName}} _{{ResourceLocation}}. There you will find the IP Address 'kubernes-<id>', possibly the second in the list of the service which can now be added to your external DNS.

Make sure you have logged into your Azure Command shell and correct subscription:

     az login
     az account set --subscription "mySubscriptionName"

### Step 2 - Installation

Run the initialize powershell command, this will ask for the basic setup properties:

* Resource Group {{ResourceGroup}} i.e. n1siccardev
* Installation Name {{InstallationName}} i.e. n1siccardev
* Installation DNS Name as is used with for SSL Certificate i.e. n1.siccar.dev
* Resource Group to install into  i.e. n1siccardev
* A required PAT Token for access to the Deployment ACR is required i.e. hlaquoruwmp25rd...nhhdltprvvobzwujts3q

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

### Step 3 - Configuration

Its time to deploy the Connection Strings as Kubernetes Secrets, you will be asked for the following information:

* MongoDB Connection String : Can be retrieved from the Azure Portal UI under the DB Settings > ConnectionStrings

!! Check your SSL Certificate are in the ./certificates directory

It can be applied on the command line or will prompt for the values

     ./apply_connections.ps1

### Step 4

Configuring inbound access via ingress-nginx, with SSL.

     ./apply_proxy.ps1

!! If this script fails, it may be due to the ingress controller not having fully deployed. Its worth a retry after a few minutes.

### Step 5

Configure the Azure Key Vault Service for Wallet Protection, first you must run the script which will create the Key Vault  

#### Azure Keyvault Service

* Infrastructure Tenant ID - the directory of the Managed Service Identity
* Application ClientID, the guid of teh registered AD Application
* Application Secret, the secret created in the SiccarV3 app authentication setup stage

     ./apply_keyvault.ps1

!! Currently you will now need to use the Azure Key Vault Web UI Settings > Access Policy to ensure that Application SiccarV3 has the following permissions

* get Key
* wrapKey
* unWrapKey
* get Secret
* list Secret
* set Secret

Further ensure that Key Vault has enabled access to (Check boxes ticked)

* Azure Virtual Machines for Deployment
* Azure Disk Encryption for Volume encryption

#### Ensure configuration of the MySQL store

Setting the wallet service SQL store. Get the connection string from the Azure portal but is in the form:

Server="{{InstallationName}}.mysql.database.azure.com";UserID="siccaradmin";Password="{{MYSQL_PASSWORD}}";Database="wallets";

The Databasename is important!


     ./apply_mysql {{MYSQL_Connection}}

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

Now fixup the Tenant-Service, we need to seed the Database with a default tenant and copy the SSL Certificate into the Tenant Service, you need to ensure teh DNS and routing is working - which it should be, test by hitting <https://{{dns_name}}> and you should be returned 'ok'

* Create and embed SSL certificate in Tenant/Identity Server - copy into persistent volume and update yaml paths
* Configure and Initialise database

     ./apply_tenant.ps1 {{SiccarV3Tenant}} {{SiccarAppID}} {{admin_email}}

!! If the apply_tenant fails, then you may need to reset the deployment yaml file (deployments/deploy-microservice-tenant.yaml), or get the ID from the MongoDB Document to set the default tenant.

As long as the Tenant exists and Service has the environment variable DEFAULTTENANT then the service should start fine.

At this point you should be able to sign in using, which will now require the ~/.siccar/appsettings.json to be edited

     {
          /* Siccar Configuration */
          "SiccarService": "https://demo.siccar.dev/"  
     }

You can then login:

     dotnet siccarcmd auth login

### Validate the Service

There a number of quick checks you can perform to ensure the service is operationally up at this point:

* Hit <https://{{dns_name}}> and you should be returned 'ok'
* Hit <https://{{dns_name}}}/.well-known/openid-configuration> and you should get returned the Identity metadata, ensure the issuer names are corrent.
* Hit <https://{{dns_name}}}}/odata/registers/$metadata> and you should be returned the Register Service OData definition

 To test the service is fully commisioned run the pingpong test, this may require some initial configuration to grant the correct access roles to the user.

## Updating

The release notes will detail any specific change in the services, there are a few common practices here:

To update the installation ACR with the latest runtime images using the 'installer' id and time limited PAT token

     .\copy_dev_acr.ps1 {{your_acr_name}} {{installed_id}} {{installer_PAT}}

## Troubleshooting and other useful stuff

the current images can be debug enabled by setting the following environment variable in the microservice deploymnet yaml.

     - name: ASPNETCORE_ENVIRONMENT
       value: "Development"

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

### SSL Help

Please create an SSL Certiifcate for the installation with an appropriate DNS name
You may depending on setup need it in two formats (ingress & identity server):

1. For the Nginx Ingress inbound SSL (.crt + .pem)
2. For the Signing of JWT Tokens in TenatService (.pfx + password)

If the password is differnet from that configured in the YAML file please change it.

place the following files in this directory named as follows:

     <installationName>.crt
     <installationName>.key

     <installationName>.pfx

OpenSSL Commands:

From PFX

Get the .key

    openssl pkcs12 -in [installationName.pfx] -nocerts -out [installationName-encrypted.key]

extract private key data

    openssl rsa -in [installationName-encrypted.key] -out [keyfilename-decrypted.key]

Get the .crt

    openssl pkcs12 -in [installationName.pfx] -clcerts -nokeys -out [installationName.crt]

From

    openssl pkcs12 -export -out installationName.pfx -inkey installationName.key -in installationName.crt

Viw pfx details

    openssl pkcs12 -info -in certificate.pfx -nodes
