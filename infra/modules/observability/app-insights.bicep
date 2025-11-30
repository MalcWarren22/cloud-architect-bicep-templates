@description('Application Insights name')
param name string

@description('Location')
param location string

@description('Log Analytics workspace resource ID')
param workspaceId string

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  kind: 'web'
  properties: {
    Application_Type:    'web'
    Flow_Type:           'Bluefield'
    WorkspaceResourceId: workspaceId
  }
}

// Diagnostics
resource appInsightsDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(workspaceId)) {
  name: '${name}-diag'
  scope: appInsights
  properties: {
    workspaceId: workspaceId
    logs: [
      { category: 'AppTraces',         enabled: true }
      { category: 'PerformanceCounters', enabled: true }
      { category: 'Exceptions',        enabled: true }
    ]
    metrics: [
      { category: 'AllMetrics', enabled: true }
    ]
  }
}

@description('App Insights resource ID')
output appInsightsId string = appInsights.id

@description('App Insights instrumentation key')
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey

@description('App Insights connection string')
output appInsightsConnectionString string = appInsights.properties.ConnectionString
