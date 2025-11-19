@description('Name of the private endpoint')
param name string

@description('Target resource ID to connect to (e.g. Key Vault, Storage, SQL)')
param targetResourceId string

@description('Subnet ID where the private endpoint will live')
param subnetId string

@description('Group ID for the private link service (e.g. vault, blob, sqlServer)')
param groupId string

@description('Enable linking to a Private DNS zone')
param enablePrivateDns bool = false

@description('Private DNS zone resource ID (required when enablePrivateDns = true)')
param privateDnsZoneId string = ''

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  id: subnetId
}

resource pe 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: name
  location: resourceGroup().location
  properties: {
    subnet: {
      id: subnet.id
    }
    privateLinkServiceConnections: [
      {
        name: '${name}-pls'
        properties: {
          privateLinkServiceId: targetResourceId
          groupIds: [
            groupId
          ]
        }
      }
    ]
  }
}

resource peDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = if (enablePrivateDns) {
  name: 'default'
  parent: pe
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

@description('Private endpoint resource ID')
output privateEndpointId string = pe.id
