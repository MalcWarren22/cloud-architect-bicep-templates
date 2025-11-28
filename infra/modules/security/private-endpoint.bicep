@description('Location for the private endpoint')
param location string

@description('Environment name (dev/test/prod)')
param environment string

@description('Resource name prefix applied to this resource')
param resourceNamePrefix string

@description('Tags to apply')
param tags object

@description('Subnet ID where the private endpoint will be placed')
param vnetSubnetId string

@description('Resource ID of the target service')
param targetResourceId string

@description('Subresource/group name (e.g. "vault", "blob", "sqlServer")')
param subResourceName string

// Use resourceNamePrefix + environment in the name so param is not unused
var peName = '${resourceNamePrefix}-pe-${subResourceName}-${environment}'

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-04-01' = {
  name: peName
  location: location
  tags: tags
  properties: {
    subnet: {
      id: vnetSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${peName}-pls'
        properties: {
          privateLinkServiceId: targetResourceId
          groupIds: [
            subResourceName
          ]
        }
      }
    ]
  }
}

output privateEndpointId string = privateEndpoint.id
