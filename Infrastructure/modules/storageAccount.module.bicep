@description('Name for the storage account')
param storageAccountName string
@description('Location for resource.')
param location string
@description('Storage Account type')
@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_LRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Standard_ZRS'
])
param storageAccountType string = 'Standard_LRS'
@description('Identity of DataFactory to provision RBAC Access')
param dataFactoryIdentityId string


resource sa 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: toLower(replace('sa${storageAccountName}','-',''))
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
  properties: {}
}

@description('This is the built-in Contributor role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#contributor')
resource blobDataContributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
}

resource dataFactoryRBAC 'Microsoft.Authorization/roleAssignments@2022-04-01'={
  name: guid(dataFactoryIdentityId, sa.id, blobDataContributorRoleDefinition.id)
  properties: {
    roleDefinitionId: blobDataContributorRoleDefinition.id
    principalId: dataFactoryIdentityId
    principalType: 'ServicePrincipal'
    scope: sa
  }
}
