targetScope = 'subscription'

@description('List of role assignments')
param assignments array
// expected: [{ principalId: string, roleDefinitionId: string, scope: string }]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for assignment in assignments: {
  name: guid(assignment.scope, assignment.principalId, assignment.roleDefinitionId)
  scope: resourceGroup(assignment.scope)
  properties: {
    principalId: assignment.principalId
    roleDefinitionId: assignment.roleDefinitionId
    principalType: 'ServicePrincipal'
  }
}]
