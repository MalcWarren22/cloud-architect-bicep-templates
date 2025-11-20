@description('Array of target resource IDs')
param targets string[]

@description('Log Analytics workspace ID')
param workspaceId string

@description('Diagnostic setting name prefix')
param namePrefix string = 'diag'

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

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
  for (targetId, i) in targets: {
    name: '${namePrefix}-${i}'
    scope: targetId
    properties: {
      workspaceId: workspaceId
      logs: logs
      metrics: metrics
    }
  }
]
