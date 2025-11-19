@description('Name of the virtual network')
param name string

@description('Address space of the virtual network (CIDR)')
param addressSpace string

@description('Array of subnet definitions')
param subnets array

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: name
  location: resourceGroup().location
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
          // Optional: in the future you can add delegations, serviceEndpoints, etc.
        }
      }
    ]
  }
}

@description('Virtual network resource ID')
output vnetId string = vnet.id

@description('Subnets IDs in the same order as the input array')
output subnetIds array = [for s in vnet.properties.subnets: s.id]
