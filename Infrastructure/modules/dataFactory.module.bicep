@description('Name for the data factory')
param dataFactoryName string
@description('Location for resource.')
param location string
@description('Log Analytics WorksSpaceID')
param logAnalyticsWorkspaceId string
@description('GitHub account')
param gitHubAccountName string 
@description('GitHub collobration branch')
param gitHubCollobarationBranch string 
@description('GitHub repository name')
param gitHubRepositoryName string
@description('Azure Data Factory Root Folder')
param gitHubADFRootFolder string
@description('Publish from branch')
param disablePublish bool = true




resource df 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: 'adf-${dataFactoryName}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
   repoConfiguration: !empty(gitHubAccountName) ? { 
      type: 'FactoryGitHubConfiguration'
      accountName: gitHubAccountName
      rootFolder: gitHubADFRootFolder
      disablePublish:disablePublish
      collaborationBranch:gitHubCollobarationBranch
      repositoryName: gitHubRepositoryName
    }: {disablePublish:disablePublish}
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
output dataFactoryIdentityId string = df.identity.principalId

