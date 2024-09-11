@description('Name for the data factory')
param logAnalyticsName string
@description('Location for resource.')
param location string

resource la 'Microsoft.OperationalInsights/workspaces@2023-09-01'= {
  name: 'la-${logAnalyticsName}'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}
output logAnalyticsWorkspaceId string = la.id
