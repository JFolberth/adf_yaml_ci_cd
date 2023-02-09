@description('Name for the data factory')
param dataFactoryName string
@description('Location for resource.')
param location string
@description('Log Analytics WorksSpaceID')
param logAnalyticsWorkspaceId string
@description('GitHub account')
param gitHubAccountName string = 'JFolberth'
@description('GitHub collobration branch')
param gitHubCollobarationBranch string = 'main'
@description('GitHub repository name')
param gitHubRepositoryName string = 'adf_pipelines_yaml_ci_cd'
@description('Publish from branch')
param publishFromBranch bool = true
@description('Azure Data Factory Root Folder')
param gitHubADFRootFolder string = 'adf'




resource df 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: 'adf-${dataFactoryName}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    repoConfiguration: {
      type: 'FactoryGitHubConfiguration'
      accountName: gitHubAccountName
      rootFolder: gitHubADFRootFolder
      disablePublish:publishFromBranch
      collaborationBranch:gitHubCollobarationBranch
      repositoryName: gitHubRepositoryName
    }
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

