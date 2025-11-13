targetScope = 'resourceGroup'

@description('Function App name')
param functionAppName string

@description('Location')
param location string

@description('Storage account name for Function App')
param storageAccountName string

@description('App Service plan name (consumption or premium)')
param appServicePlanName string

resource sa 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

resource plan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

resource func 'Microsoft.Web/sites@2023-12-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp,linux'
  properties: {
    serverFarmId: plan.id
    httpsOnly: true
  }
}

output functionAppId string = func.id
output defaultHostName string = func.properties.defaultHostName
