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

var vnetName = '${namePrefix}-${environmentName}-vnet'
var lawName = '${namePrefix}-${environmentName}-law'
var appServicePlanName = '${namePrefix}-${environmentName}-asp'
var appName = '${namePrefix}-${environmentName}-webapi'
var keyVaultName = toLower('${namePrefix}-${environmentName}-kv')
var storageAccountName = toLower(replace('${namePrefix}${environmentName}sa', '-', ''))

//
// 1) Networking – Spoke VNet
//
module vnetSpoke '../modules/networking/vnet-spoke.bicep' = {
  name: 'vnetSpoke'
  params: {
    vnetName: vnetName
    location: location
    addressSpace: vnetAddressSpace
    subnets: [
      {
        name: 'web'
        addressPrefix: '10.20.1.0/24'
      }
      {
        name: 'app'
        addressPrefix: '10.20.2.0/24'
      }
      {
        name: 'data'
        addressPrefix: '10.20.3.0/24'
      }
    ]
  }
}

//
// 2) Monitoring – Log Analytics + App Insights
//
module monitoring '../modules/observability/monitoring-core.bicep' = {
  name: 'monitoringCore'
  params: {
    lawName: lawName
    location: location
    appInsightsName: '${appName}-ai'
  }
}

//
// 3) Security – Key Vault
//
module kv '../modules/security/keyvault.bicep' = {
  name: 'keyVault'
  params: {
    keyVaultName: keyVaultName
    location: location
    skuName: 'standard'
  }
}

//
// 4) Data – Storage Account
//
module storage '../modules/data/storage-account.bicep' = {
  name: 'storageAccount'
  params: {
    storageAccountName: storageAccountName
    location: location
  }
}

//
// 5) Compute – Web API on App Service
//
module webApi '../modules/compute/appservice-webapi.bicep' = {
  name: 'webApi'
  params: {
    appServicePlanName: appServicePlanName
    webAppName: appName
    location: location
    skuName: appServiceSkuName
    skuTier: appServiceSkuTier
  }
}

//
// 6) Diagnostics – App Service logs to Log Analytics
//
module appDiag '../modules/observability/diagnostics-to-law.bicep' = {
  name: 'appServiceDiagnostics'
  params: {
    resourceId: webApi.outputs.webAppId
    workspaceId: monitoring.outputs.lawId
  }
}

output vnetId string = vnetSpoke.outputs.vnetId
output webAppUrl string = webApi.outputs.webAppDefaultHostName
output keyVaultUri string = kv.outputs.keyVaultUri
output logAnalyticsWorkspaceId string = monitoring.outputs.lawId
output storageAccountId string = storage.outputs.storageAccountId
