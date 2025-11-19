@description('Array of RBAC role assignments')
param assignments array

// Each item:
// {
//   scope: string
//   roleDefinitionId: string
//   principalId: string
//   principalType: string // User, ServicePrincipal, Group, etc.
// }

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for a in assignments: {
  name: guid(a.scope, a.roleDefinitionId, a.principalId)
  scope: a.scope
  properties: {
    principalId: a.principalId
    roleDefinitionId: a.roleDefinitionId
    principalType: a.principalType
  }
}]
