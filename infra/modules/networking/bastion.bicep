targetScope = 'resourceGroup'

@description('Bastion host name')
param bastionName string

@description('Location')
param location string

@description('Subnet ID for AzureBastionSubnet')
param subnetId string

@description('Public IP name for bastion')
param publicIpName string

resource publicIp 'Microsoft.Network/publicIPAddresses@2024-03-01' = {
  name: publicIpName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2024-03-01' = {
  name: bastionName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'bastion-ipconfig'
        properties: {
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
  }
}
