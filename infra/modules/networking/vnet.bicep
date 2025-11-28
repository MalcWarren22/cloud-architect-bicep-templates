@description('Location of the virtual network')
param location string

@description('Environment name (dev/test/prod)')
param environment string

@description('Resource name prefix')
param resourceNamePrefix string

@description('Tags to apply')
param tags object

@description('VNet address space')
param addressSpace string

@description('App subnet CIDR')
param appSubnetPrefix string

@description('Data subnet CIDR')
param dataSubnetPrefix string

@description('Monitor subnet CIDR')
param monitorSubnetPrefix string

var vnetName = '${resourceNamePrefix}-vnet-${environment}'

resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressSpace
      ]
    }
    subnets: [
      {
        name: 'app'
        properties: {
          addressPrefix: appSubnetPrefix
        }
      }
      {
        name: 'data'
        properties: {
          addressPrefix: dataSubnetPrefix
        }
      }
      {
        name: 'monitor'
        properties: {
          addressPrefix: monitorSubnetPrefix
        }
      }
    ]
  }
}

@description('VNet resource ID')
output vnetId string = vnet.id

@description('App subnet resource ID')
output appSubnetId string = vnet.properties.subnets[0].id

@description('Data subnet resource ID')
output dataSubnetId string = vnet.properties.subnets[1].id

@description('Monitor subnet resource ID')
output monitorSubnetId string = vnet.properties.subnets[2].id