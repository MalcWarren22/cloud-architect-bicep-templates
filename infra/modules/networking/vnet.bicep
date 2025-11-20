@description('Location of the virtual network')
param location string

@description('Environment name (dev/test/prod)')
param environment string

@description('Resource name prefix for the VNet')
param resourceNamePrefix string

@description('Tags to apply')
param tags object

@description('CIDR for the VNet')
param addressSpace string

@description('CIDR for the app subnet (optional)')
param appSubnetPrefix string = ''

@description('CIDR for the data subnet (optional)')
param dataSubnetPrefix string = ''

@description('CIDR for the monitor subnet (optional)')
param monitorSubnetPrefix string = ''

var vnetName = '${resourceNamePrefix}-vnet-${environment}'

var subnets = [
  if (!empty(appSubnetPrefix)) {
    name: 'app'
    properties: {
      addressPrefix: appSubnetPrefix
    }
  }
  if (!empty(dataSubnetPrefix)) {
    name: 'data'
    properties: {
      addressPrefix: dataSubnetPrefix
    }
  }
  if (!empty(monitorSubnetPrefix)) {
    name: 'monitor'
    properties: {
      addressPrefix: monitorSubnetPrefix
    }
  }
]

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
    subnets: subnets
  }
}

@description('ID of the VNet')
output vnetId string = vnet.id

@description('Map of subnet name -> subnet id')
output subnetIds object = {
  for s in vnet.properties.subnets: s.name: s.id
}

@description('App subnet id (if defined)')
output appSubnetId string = contains(subnetIds, 'app') ? subnetIds['app'] : ''

@description('Data subnet id (if defined)')
output dataSubnetId string = contains(subnetIds, 'data') ? subnetIds['data'] : ''

@description('Monitor subnet id (if defined)')
output monitorSubnetId string = contains(subnetIds, 'monitor') ? subnetIds['monitor'] : ''
