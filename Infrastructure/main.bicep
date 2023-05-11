@description('Location for all resources.')
param location string
@description('Base name that will appear for all resources.') 
param baseName string = 'adfdemo'
@description('Three letter environment abreviation to denote environment that will appear in all resource names') 
param environmentName string = 'dev'
@description('Storage Account type')
param storageAccountType string = 'Standard_LRS'
@description('GitHub account')
param gitHubAccountName string = ''
@description('GitHub collobration branch')
param gitHubCollobarationBranch string = ''
@description('GitHub repository name')
param gitHubRepositoryName string = ''
@description('Azure Data Factory Root Folder')
param gitHubADFRootFolder string = ''

targetScope = 'subscription'

var regionReference = {
  centralus: 'cus'
  eastus: 'eus'
  westus: 'wus'
  westus2: 'wus2'
}
var nameSuffix = '${baseName}-${environmentName}-${regionReference[location]}'
var resourceGroupName = 'rg-${nameSuffix}'

/* Since we are mismatching scopes with a deployment at subscription and resource at resource group
 the main.bicep requires a Resource Group deployed at the subscription scope, all modules will be at the Resourece Group scope
 */
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' ={
  name: resourceGroupName
  location: location
  tags:{
    Department: 'DataFactory'
  }
}

module dataFactory 'modules/dataFactory.module.bicep' ={
  name: 'dataFactoryModule'
  scope: resourceGroup
  params:{
    location: location
    dataFactoryName: nameSuffix
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
    gitHubAccountName: gitHubAccountName
    gitHubCollobarationBranch: gitHubCollobarationBranch
    gitHubRepositoryName: gitHubRepositoryName
    gitHubADFRootFolder: gitHubADFRootFolder
  }
}

module logAnalytics 'modules/logAnalytics.module.bicep' ={
  name: 'logAnalyticsModule'
  scope: resourceGroup
  params:{
    location: location
    logAnalyticsName: nameSuffix
  }
}

module storageAccount 'modules/storageAccount.module.bicep' ={
  name: 'storageAccountModule'
  scope: resourceGroup
  params:{
    location: location
    storageAccountName: nameSuffix
    storageAccountType: storageAccountType
    dataFactoryIdentityId: dataFactory.outputs.dataFactoryIdentityId
  }
}
