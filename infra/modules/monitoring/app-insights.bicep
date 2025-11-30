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
// Application Insights - Workspace based
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
    WorkspaceResourceId: logAnalyticsWorkspaceId
  }
}

// Diagnostic settings
resource appInsightsDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  name: '${appInsightsName}-diag'
  scope: appInsights
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    // Logs block removed because category 'Requests' is not supported for this resource.
    // App Insights is already workspace-based, so data still lands in Log Analytics.
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

output appInsightsName string = appInsights.name
output instrumentationKey string = appInsights.properties.InstrumentationKey
output connectionString string = appInsights.properties.ConnectionString
