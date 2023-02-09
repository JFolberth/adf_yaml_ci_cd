@description('Name for the data factory')
param dataFactoryName string
@description('Location for resource.')
param location string


resource df 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: location
  identity: {
    type: 'SystemAssigned'
  }

}
