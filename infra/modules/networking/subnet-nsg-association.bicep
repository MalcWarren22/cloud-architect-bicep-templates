@description('Subnet resource ID to attach the NSG to')
param subnetId string

@description('Network Security Group resource ID')
param nsgId string

resource subnetNsgAssoc 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  id: subnetId
}

resource nsgAssoc 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  name: subnetNsgAssoc.name
  parent: subnetNsgAssoc.parent
  properties: {
    networkSecurityGroup: {
      id: nsgId
    }
  }
}
