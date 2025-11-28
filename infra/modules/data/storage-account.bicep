@description('Location for the storage account')
param location string

@description('Environment name')
param environment string

@description('Resource name prefix')
param resourceNamePrefix string

@description('Tags to apply')
param tags object

@description('Subnet ID for future private endpoint (not used directly here)')
param vnetSubnetId string

var stgName = toLower(replace('${resourceNamePrefix}stg${environment}', '-', ''))

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: stgName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
  }
}

output storageId string = storage.id
output blobEndpoint string = storage.properties.primaryEndpoints.blob

// Convenience outputs to match Project A expectations
output storageAccountId string = storage.id
output primaryBlobEndpoint string = storage.properties.primaryEndpoints.blob