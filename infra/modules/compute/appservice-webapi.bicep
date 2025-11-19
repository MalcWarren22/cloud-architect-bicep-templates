@description('Name of the Web App')
param name string

@description('Location of the Web App')
param location string

@description('App Service plan SKU name (e.g. P1v2, B1)')
param skuName string = 'B1'

@description('App Service plan SKU tier (e.g. Basic, Standard, PremiumV2)')
param skuTier string = 'Basic'

@description('Subnet ID for VNet integration')
param subnetId string

@description('App settings for the Web App')
param appSettings object = {}

@description('Optional Log Analytics workspace ID for diagnostics')
param logAnalyticsWorkspaceId string = ''

resource plan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: '${name}-plan'
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    reserved: true // Linux
  }
}

resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: name
  location: location
  kind: 'app,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: plan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
      appSettings: [
        for settingName in union([], appSettings): {
          name: settingName
          value: appSettings[settingName]
        }
      ]
      virtualNetworkSubnetId: subnetId
    }
  }
}

resource appDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  name: '${name}-diag'
  scope: webApp
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'AppServiceHTTPLogs'
        enabled: true
      }
      {
        category: 'AppServiceConsoleLogs'
        enabled: true
      }
      {
        category: 'AppServiceAppLogs'
        enabled: true
      }
      {
        category: 'AppServicePlatformLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

@description('Web App resource ID')
output webAppId string = webApp.id

@description('Web App default hostname')
output hostname string = webApp.properties.defaultHostName

@description('Managed identity principal ID')
output principalId string = webApp.identity.principalId
