@description('Location for App Service')
param location string

@description('Environment name')
param environment string

@description('Resource name prefix')
param resourceNamePrefix string

@description('Tags to apply')
param tags object

@description('Subnet ID for VNet integration')
param subnetId string

@description('Key Vault URI (for app settings, optional)')
param keyVaultUri string

var planName = '${resourceNamePrefix}-plan-${environment}'
var appName  = '${resourceNamePrefix}-webapi-${environment}'

resource appPlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: planName
  location: location
  sku: {
    name: 'P1v3'
    tier: 'PremiumV3'
    size: 'P1v3'
    capacity: 1
  }
  tags: tags
}

resource webApp 'Microsoft.Web/sites@2022-09-01' = {
  name: appName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appPlan.id
    httpsOnly: true
    siteConfig: {
      virtualNetworkSubnetId: subnetId
      appSettings: [
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: environment
        }
        {
          name: 'KEYVAULT_URI'
          value: keyVaultUri
        }
      ]
    }
  }
}

output webAppId string = webApp.id
output hostname string = webApp.properties.defaultHostName
output principalId string = webApp.identity.principalId

// For Project A expectations
output appServiceName string = webApp.name
