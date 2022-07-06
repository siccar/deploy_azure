# A Power shell script that will setup the Wallet Service
# Requires the other configuration items plus a connection to Azure DB for MySQL
#
# if you want to use the Az MySQL Module install by running below:
#   Install-Module -Name Az.MySql -AllowPrerelease
#
# for more on commandline deployment of MySQl 
#   https://docs.microsoft.com/en-us/azure/mysql/single-server/quickstart-create-mysql-server-database-using-azure-powershell 
#

[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)] [string] $walletConnection='Information'
)

# the idea would be to get the connection string thus:      -requires preview AzMySQL

#Get-AzMySqlConnectionString -name $env:InstallationName -resourcegroupname $env:ResourceGroup -client ado.net

# eg: Server=mysql-test.mysql.database.azure.com; Port=3306; Database={your_database}; Uid=mysql_test@mysql-test; Pwd={your_password};
$walletConnection = ""

kubectl create secret generic registerrepository --from-literal=repo=$walletConnection -n default