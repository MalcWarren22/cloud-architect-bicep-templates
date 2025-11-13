targetScope = 'resourceGroup'

@description('Hub VNet name')
param vnetName string

@description('Location')
param location string

@description('Hub address space')
param addressSpace string = '10.0.0.0/16'

@description('Subnets for hub: [{ name, addressPrefix }]')
param subnets array = [
  {
    name: 'AzureFirewallSubnet'
    addressPrefix: '10.0.0.0/24'
  }
  {
    name: 'GatewaySubnet'
    addressPrefix: '10.0.1.0/24'
  }
  {
    name: 'SharedServices'
    addressPrefix: '10.0.2.0/24'
  }
]

resource vnet 'Microsoft.Network/virtualNetworks@2024-03-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressSpace
      ]
    }
    subnets: [
      for subnet in subnets: {
        name: subnet.name
        properties: {
          addressPrefix: subnet.addressPrefix
        }
      }
    ]
  }
}

output vnetId string = vnet.id
