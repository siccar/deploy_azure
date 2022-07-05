# Siccar Installation Deployment

The following procedure should help you get Siccar up and running in your own Azure Tenant.

The installation configured is suitable for test and build purposes, further refinements can and should be made for a scalable deployment.
## Steps

Documentation and tooling to deploy a Siccar installation

Within your choosen environment download this tool

     git clone https://github.com/siccar/deploy

Follow the steps to setup up the Azure Infrastructure

### Step 0

Get your stuff together:

1. Decide and note the names for the installation i.e. n1siccardev
2. Note its fully qualified DNS domain name i.e n1.siccar.dev
3. Create your SSL Certificate and place the files in the ./components directory naming the files 'installationName'.crt and 'installationName'.key i.e. n1siccardev.crt  

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

Now setup the Tenant-Service, we will use the MongoDB API for Cosmos and configure the SSL Certificate for use with the STS

* Configure and Initialise database
* Create and embed SSL certificate in Tenant/Identity Server

     ./apply_tenant.ps1

### Step 3

Its time to deploy the Wallet-Service

     ./apply_wallet.ps1

### Step 4

Configuring inbound access via ingress-nginx, with SSL

     ./apply_proxy.ps1

### Validate the Service

To test the service is fully commisioned run the pingpong test.

## Troubleshooting

Checking your environment variables; look for InstallationName, ResourceGroup, ResourceLocation

     dir env:

Looking at pod status:

     kubectl get pods
     kubectl describe pod <pod_name>

If AKS cannot pull images from the ACR

      az aks update -n <installation_name> -g <resource_group> --attach-acr <installation_name>cr ## <- watch the CR not _acr_

Examine the state of DAPR, should open a Browser windows to localhost:8888

     dapr dashboard -k -p 8888
