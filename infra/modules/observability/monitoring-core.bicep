targetScope = 'resourceGroup'

@description('Log Analytics workspace name')
param lawName string

@description('Azure region')
param location string

@description('Application Insights name')
param appInsightsName string

resource law 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: lawName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: law.id
  }
}

output lawId string = law.id
output appInsightsConnectionString string = appInsights.properties.ConnectionString
