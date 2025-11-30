@description('Location for the Application Insights resource')
param location string

@description('Environment name (e.g. dev, test, prod)')
param environment string

@description('Resource name prefix applied to the App Insights instance')
param resourceNamePrefix string

@description('Tags to apply')
param tags object

@description('Name of the App Service associated with this App Insights')
param appServiceName string

@description('Log Analytics Workspace resource ID')
param logAnalyticsWorkspaceId string

var appInsightsName = '${resourceNamePrefix}-appi-${environment}'

// ------------------------------------------
// Application Insights - workspace-based
// ------------------------------------------
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  tags: union(tags, {
    monitoredApp: appServiceName
  })
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    WorkspaceResourceId: logAnalyticsWorkspaceId
  }
}

// ------------------------------------------
// Diagnostic settings 
// ------------------------------------------
resource appInsightsDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  name: '${appInsightsName}-diag'
  scope: appInsights
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'AppTraces'
        enabled: true
      }
      {
        category: 'AppPerformanceCounters'
        enabled: true
      }
      {
        category: 'AppExceptions'
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

@description('App Insights resource ID')
output appInsightsId string = appInsights.id

@description('App Insights instrumentation key')
output instrumentationKey string = appInsights.properties.InstrumentationKey

@description('App Insights connection string')
output connectionString string = appInsights.properties.ConnectionString
