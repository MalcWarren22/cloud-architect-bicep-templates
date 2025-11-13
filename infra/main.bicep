targetScope = 'resourceGroup'

@description('Environment name (dev, test, prod, etc.)')
param environmentName string

@description('Azure region')
param location string = resourceGroup().location

@description('Name prefix for resources')
param namePrefix string = 'corp'

@description('Address space for the spoke VNet')
param vnetAddressSpace string = '10.20.0.0/16'

@description('App Service SKU name (e.g. P1v3, B1, S1)')
param appServiceSkuName string = 'P1v3'

@description('App Service SKU tier')
param appServiceSkuTier string = 'PremiumV3'

// Just call the webapp scenario and forward the params
module webapp 'scenarios/webapp-landing-zone.bicep' = {
  name: 'webapp-landing-zone'
  params: {
    environmentName: environmentName
    location: location
    namePrefix: namePrefix
    vnetAddressSpace: vnetAddressSpace
    appServiceSkuName: appServiceSkuName
    appServiceSkuTier: appServiceSkuTier
  }
}

// Bubble up useful outputs
output vnetId string = webapp.outputs.vnetId
output webAppUrl string = webapp.outputs.webAppUrl
output keyVaultUri string = webapp.outputs.keyVaultUri
output logAnalyticsWorkspaceId string = webapp.outputs.logAnalyticsWorkspaceId
output storageAccountId string = webapp.outputs.storageAccountId
