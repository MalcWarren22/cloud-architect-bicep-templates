@description('Name of the Network Security Group')
param name string

@description('Array of security rules for the NSG')
param rules array

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-03-01' = {
  name: name
  location: resourceGroup().location
  properties: {
    securityRules: [
      for rule in rules: {
        name: rule.name
        properties: {
          description: rule.description
          protocol: rule.protocol
          sourcePortRange: rule.sourcePortRange
          destinationPortRange: rule.destinationPortRange
          sourceAddressPrefix: rule.sourceAddressPrefix
          destinationAddressPrefix: rule.destinationAddressPrefix
          access: rule.access
          priority: rule.priority
          direction: rule.direction
        }
      }
    ]
  }
}

@description('NSG resource ID')
output nsgId string = nsg.id
