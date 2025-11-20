@description('Resource ID of VNet A (hub)')
param hubVnetId string

@description('Resource ID of VNet B (spoke)')
param spokeVnetId string

@description('Allow forwarded traffic')
param allowForwardedTraffic bool = true

@description('Allow gateway transit')
param allowGatewayTransit bool = true

resource hubVnet 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: last(split(hubVnetId, '/'))
}

resource spokeVnet 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: last(split(spokeVnetId, '/'))
}

// hub -> spoke
resource hubToSpoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = {
  name: 'hub-to-spoke'
  parent: hubVnet
  properties: {
    allowForwardedTraffic: allowForwardedTraffic
    allowGatewayTransit: allowGatewayTransit
    allowVirtualNetworkAccess: true
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: spokeVnetId
    }
  }
}

// spoke -> hub
resource spokeToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = {
  name: 'spoke-to-hub'
  parent: spokeVnet
  properties: {
    allowForwardedTraffic: allowForwardedTraffic
    allowGatewayTransit: false
    allowVirtualNetworkAccess: true
    useRemoteGateways: true
    remoteVirtualNetwork: {
      id: hubVnetId
    }
  }
}
