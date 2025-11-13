targetScope = 'resourceGroup'

@description('Name of the App Service (Microsoft.Web/sites) to enable diagnostics on')
param webAppName string

@description('Log Analytics workspace resource ID')
param workspaceId string

// Reference the existing Web App in this resource group
resource webApp 'Microsoft.Web/sites@2023-12-01' existing = {
  name: webAppName
}

resource diag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'to-law'
  scope: webApp
  properties: {
    workspaceId: workspaceId
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
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}
