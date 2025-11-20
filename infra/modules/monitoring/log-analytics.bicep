@description('Location for the Log Analytics workspace')
param location string

@description('Environment name (e.g. dev, test, prod)')
param environment string

@description('Resource name prefix applied to the workspace')
param resourceNamePrefix string

@description('Tags to apply to the workspace')
param tags object

@description('Retention in days for logs')
param retentionInDays int = 30

var workspaceName = '${resourceNamePrefix}-law-${environment}'

// ------------------------------------------
// Log Analytics Workspace
// ------------------------------------------
resource logWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: retentionInDays
  }
}

output workspaceId string = logWorkspace.id
output workspaceName string = logWorkspace.name
output workspaceCustomerId string = logWorkspace.properties.customerId
