targetScope = 'resourceGroup'

@description('Name of the policy assignment')
param name string

@description('Policy definition ID to assign')
param policyDefinitionId string

@description('Optional policy parameters object')
param parameters object = {}

resource assignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: name
  properties: {
    policyDefinitionId: policyDefinitionId
    parameters: parameters
  }
}

@description('Policy assignment ID')
output policyAssignmentId string = assignment.id
