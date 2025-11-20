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

@description('ID of the VNet')
output vnetId string = vnet.id

@description('Map of subnet name -> subnet id')
output subnetIds object = {
  for s in vnet.properties.subnets: s.name: s.id
}

@description('App subnet id')
output appSubnetId string = subnetIds['app']

@description('Data subnet id')
output dataSubnetId string = subnetIds['data']

@description('Monitor subnet id')
output monitorSubnetId string = subnetIds['monitor']
