# Siccar Installation Deployment for AZURE

The following procedure should help you get Siccar up and running in your own Azure Tenant.

The installation configured is suitable for test and build purposes, further refinements can and should be made for a scalable and secure deployment.

This procedure should be run using a computer with the follwoing tooling

* Microsoft .Net 6 Framework https://dotnet.microsoft.com/en-us/download
* DAPR https://docs.dapr.io/getting-started/install-dapr-cli/
* kubectl kubernetes tooling https://kubernetes.io/docs/tasks/tools/

## Steps

Documentation and tooling to deploy a Siccar installation on Microsoft Azure.

The following Azure resources should be deployed in your choosen subscription and data centre location.

* Azure Kubernetes Service 
* Cosmos API For MongoDB
* Azure Database for MySQL

Once you have the ingress IP address from the AKS deployment you should add the appropriate DNS record

Within your choosen deployment environment download this tool, we currently support Powershell environments on Windows with Mac / Linux coming shortly but not currently Azure Cloud Shell until we can install DAPR tooling.

     git clone https://github.com/siccar/deploy

Follow the steps to setup up the Azure Infrastructure

### Step 0

Get your stuff together:

1. Decide and note the names for the installation i.e. n1siccardev
2. Note its fully qualified DNS domain name i.e n1.siccar.dev
3. Create your SSL Certificate and place the files in the ./components directory naming the files 'installationName'.crt and 'installationName'.key i.e. n1siccardev.crt  

Make sure you have logged into your Azure Command shell and correct subscription:

     az login
     az account set --subscription "mySubscriptionName"

### Step 1

Run the initialize powershell command, this will ask for the basic setup properties:

* Installation Name i.e. n1siccardev
* Installation DNS Name as is used with for SSL Certificate, which will be installed later
* Resource Group to install into  i.e. n1siccardev
* A PAT Token for access to the Deployment ACR i.e. hlaquoruwmp25rdfssldldvzn7nhousbnhhdltprvvobzwujts3q

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

### Step 2

Its time to deploy the Connection Strings as Kubernetes Secrets, you will be asked for the following information:

* MongoDB Connection String : Can be retrieved from the Azure Portal UI under the DB Settings > ConnectionStrings
* MYSQL Connection String : Again retrieved from the Azure Portal

It can be applied on the command line or will prompt for the values

     ./apply_connections.ps1

### Step 3

Configuring inbound access via ingress-nginx, with SSL

     ./apply_proxy.ps1

### Step 4

Configure the Azure Key Vault for Wallet Protection, you require the following information

* Azure Keyvault Connection String
* Application ClientID
* Application Secret
* Infrastructure Tenant ID - the directory of the Managed Service Identity
* An Encryption string for DB Protection : future removal

     ./apply_keyvault.ps1

### Step 5

Start the services

     ./start_services.ps1

### Step 6

Now fixup the Tenant-Service, we need to seed the Database with a default tenant and copy the SSL Certificate into the Tenant Service

* Create and embed SSL certificate in Tenant/Identity Server - copy into persistent volume and update yaml paths
* Configure and Initialise database

!! WARNING still in development

     ./apply_tenant.ps1

### Validate the Service

To test the service is fully commisioned run the pingpong test.


## Troubleshooting and other useful stuff

kubectl is your friend

     kubectl 
          get pods 
          describe pod <pod-instance-name>
          logs -f <pod-instance-name>
          exec –tty –stdin <deployment-name> -- /bin/bash
          rollout restart deployment/<deployment-name>

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
