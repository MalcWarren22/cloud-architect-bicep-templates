targetScope = 'resourceGroup'

@description('Storage account name (must be globally unique, lower case)')
param storageAccountName string

@description('Location')
param location string

@description('Sku name (e.g. Standard_LRS)')
param skuName string = 'Standard_LRS'

resource sa 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: skuName
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    supportsHttpsTrafficOnly: true
  }
}

output storageAccountId string = sa.id
output storagePrimaryEndpoint string = sa.properties.primaryEndpoints.blob
