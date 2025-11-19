@description('Log Analytics workspace name')
param name string

@description('Location')
param location string

@description('Retention in days')
param retentionInDays int = 30

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: name
  location: location
  properties: {
    retentionInDays: retentionInDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

@description('Log Analytics workspace resource ID')
output workspaceId string = workspace.id

@description('Log Analytics workspace customer ID')
output workspaceCustomerId string = workspace.properties.customerId
