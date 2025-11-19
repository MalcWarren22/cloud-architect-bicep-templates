@description('Name of the Storage Account')
param name string

@description('Deployment location')
param location string

@description('Account kind')
param kind string = 'StorageV2'

@description('SKU for Storage Account')
param skuName string = 'Standard_LRS'

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: name
  location: location
  sku: {
    name: skuName
  }
  kind: kind
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    publicNetworkAccess: 'Disabled' // forces private endpoint usage
  }
}

@description('Storage account ID')
output storageId string = storage.id

@description('Blob endpoint URL')
output blobEndpoint string = storage.properties.primaryEndpoints.blob
