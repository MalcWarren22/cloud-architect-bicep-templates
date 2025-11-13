targetScope = 'subscription'

@description('Policy assignment name')
param assignmentName string = 'baseline-governance'

@description('Display name')
param displayName string = 'Baseline governance: allowed locations'

@description('Allowed locations')
param allowedLocations array = [
  'eastus'
  'eastus2'
  'centralus'
]

resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'allowed-locations-and-tags'
  properties: {
    policyType: 'Custom'
    mode: 'All'
    displayName: displayName
    parameters: {
      allowedLocations: {
        type: 'Array'
        metadata: {
          displayName: 'Allowed locations'
        }
      }
    }
    policyRule: {
      if: {
        field: 'location'
        notIn: '[parameters(''allowedLocations'')]'
      }
      then: {
        effect: 'Deny'
      }
    }
  }
}

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2023-04-01' = {
  name: assignmentName
  properties: {
    displayName: displayName
    policyDefinitionId: policyDefinition.id
    parameters: {
      allowedLocations: {
        value: allowedLocations
      }
    }
  }
}
