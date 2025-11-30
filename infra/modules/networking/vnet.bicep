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

@description('Optional NSG resource ID for the app subnet')
param appSubnetNsgId string?

var vnetName = '${resourceNamePrefix}-vnet-${environment}'
var appSubnetName = 'app'
var dataSubnetName = 'data'
var monitorSubnetName = 'monitor'

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
        name: appSubnetName
        properties: {
          addressPrefix: appSubnetPrefix

          // Attach NSG only if provided
          networkSecurityGroup: appSubnetNsgId == null ? null : {
            id: appSubnetNsgId
          }

          // Delegate subnet for App Service VNet integration
          delegations: [
            {
              name: 'appservice-delegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: dataSubnetName
        properties: {
          addressPrefix: dataSubnetPrefix
        }
      }
      {
        name: monitorSubnetName
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
