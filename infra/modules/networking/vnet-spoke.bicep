targetScope = 'resourceGroup'

@description('Name of the VNet')
param vnetName string

@description('Location of the VNet')
param location string

@description('Address space of the VNet')
param addressSpace string

@description('Array of subnets: [{ name: string, addressPrefix: string }]')
param subnets array

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

// Build subnet IDs using the input names 
output subnetIds array = [
  for subnet in subnets: az.resourceId(
    'Microsoft.Network/virtualNetworks/subnets',
    vnetName,
    subnet.name
  )
]
