targetScope = 'resourceGroup'

@description('Key Vault name')
param keyVaultName string

@description('Location')
param location string

@description('SKU name (standard or premium)')
param skuName string = 'standard'

@description('Enabled for deployment')
param enabledForDeployment bool = true

@description('Enabled for template deployment')
param enabledForTemplateDeployment bool = true

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      name: skuName
      family: 'A'
    }
    enableSoftDelete: true
    enabledForDeployment: enabledForDeployment
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enabledForDiskEncryption: true
    softDeleteRetentionInDays: 90
    purgeProtectionEnabled: true
    accessPolicies: [] // Use RBAC or add policies in another module if needed
  }
}

output keyVaultId string = kv.id
output keyVaultUri string = kv.properties.vaultUri
