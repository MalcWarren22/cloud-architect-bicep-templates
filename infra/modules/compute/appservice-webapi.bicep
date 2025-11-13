targetScope = 'resourceGroup'

@description('Name of the App Service plan')
param appServicePlanName string

@description('Name of the Web App')
param webAppName string

@description('Location for resources')
param location string

@description('App Service plan SKU name (P1v3, B1, S1, etc.)')
param skuName string = 'P1v3'

@description('App Service plan SKU tier')
param skuTier string = 'PremiumV3'

@description('Runtime stack (Linux) e.g. DOTNETCORE|8.0, NODE|20-lts')
param linuxFxVersion string = 'NODE|20-lts'

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: skuName
    tier: skuTier
    capacity: 1
  }
  properties: {
    reserved: true // Linux
  }
}

resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: webAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      alwaysOn: true
    }
    httpsOnly: true
  }
}

output webAppId string = webApp.id
output webAppDefaultHostName string = webApp.properties.defaultHostName
