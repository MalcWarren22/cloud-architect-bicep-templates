@description('ID of the first virtual network')
param vnetAId string

@description('ID of the second virtual network')
param vnetBId string

@description('Name of peering from A to B')
param nameAToB string

@description('Name of peering from B to A')
param nameBToA string

resource vnetA 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  id: vnetAId
}

resource vnetB 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  id: vnetBId
}

resource aToB 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  name: nameAToB
  parent: vnetA
  properties: {
    remoteVirtualNetwork: {
      id: vnetBId
    }
    allowForwardedTraffic: true
    allowGatewayTransit: true
  }
}

resource bToA 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  name: nameBToA
  parent: vnetB
  properties: {
    remoteVirtualNetwork: {
      id: vnetAId
    }
    allowForwardedTraffic: true
    useRemoteGateways: true
  }
}
