targetScope = 'resourceGroup'

@description('Private endpoint name')
param privateEndpointName string

@description('Location')
param location string

@description('Subnet ID for private endpoint')
param subnetId string

@description('Target resource ID (e.g. storage account, Key Vault)')
param targetResourceId string

@description('Subresource name (e.g. blob, vault, sqlServer)')
param subresourceName string

resource pe 'Microsoft.Network/privateEndpoints@2024-03-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'connection'
        properties: {
          privateLinkServiceId: targetResourceId
          groupIds: [
            subresourceName
          ]
        }
      }
    ]
  }
}

output privateEndpointId string = pe.id
