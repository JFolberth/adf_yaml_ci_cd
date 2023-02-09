@description('Name for the data factory')
param dataFactoryName string
@description('Location for resource.')
param location string
@description('Log Analytics WorksSpaceID')
param logAnalyticsWorkspaceId string


resource df 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: 'df-${dataFactoryName}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
}
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' ={
  name: 'diagnosticSettings-${dataFactoryName}'
  scope: df
 properties: {
  logs: [
    {
      categoryGroup:'allLogs'
      enabled: true
      retentionPolicy: {
        days: 10
        enabled: true
      }
    }
  ]
  metrics: [
    {
      category: 'AllMetrics'
      enabled: true
      retentionPolicy: {
        days: 10
        enabled: true
      }
    }
  ]
  workspaceId: logAnalyticsWorkspaceId
 }
}
