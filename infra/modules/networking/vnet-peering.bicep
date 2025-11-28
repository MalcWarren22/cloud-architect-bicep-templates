@description('Location for the resource')
param location string

@description('Environment name (e.g. dev, test, prod)')
param environment string

@description('Resource name prefix applied to this resource')
param resourceNamePrefix string

@description('Tags to apply to this resource')
param tags object

@description('Resource ID of the hub VNet')
param hubVnetId string

@description('Resource ID of the spoke VNet')
param spokeVnetId string

@description('Allow forwarded traffic')
param allowForwardedTraffic bool = true

@description('Allow gateway transit from hub to spoke (only used if hub has a VPN gateway)')
param allowGatewayTransit bool = false

// Small metadata object just to consume the "common" params
var peeringMetadata = {
  location: location
  environment: environment
  resourceNamePrefix: resourceNamePrefix
  tags: tags
}

// Existing hub VNet
resource hubVnet 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: last(split(hubVnetId, '/'))
}

// Existing spoke VNet
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
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: hubVnetId
    }
  }
}

@description('Metadata for the peering (for diagnostics / linter)')
output peeringInfo object = peeringMetadata
