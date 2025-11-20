@description('Array of resource IDs to attach diagnostic settings to')
param targets array

@description('Log Analytics Workspace resource ID where diagnostics will be sent')
param workspaceId string

@description('Prefix for diagnostic setting names')
param namePrefix string = 'diag'

// Basic log categories (will be skipped silently if unsupported on a target)
var logs = [
  {
    category: 'Audit'
    enabled: true
  }
  {
    category: 'Error'
    enabled: true
  }
  {
    category: 'Request'
    enabled: true
  }
  {
    category: 'Security'
    enabled: true
  }
]

var metrics = [
  {
    category: 'AllMetrics'
    enabled: true
  }
]

// ------------------------------------------
// Diagnostic settings per target resource
// ------------------------------------------
// NOTE: targets is an array of resource IDs (strings)
resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
  for targetId in targets: {
    name: '${namePrefix}-${last(split(targetId, '/'))}'
    scope: targetId
    properties: {
      workspaceId: workspaceId
      logs: logs
      metrics: metrics
    }
  }
]
