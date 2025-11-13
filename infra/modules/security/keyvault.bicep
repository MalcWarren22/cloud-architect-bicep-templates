targetScope = 'resourceGroup'

@description('Key Vault name')
param keyVaultName string

@description('Location')
param location string

@description('SKU name (standard or premium)')
param skuName string = 'standard'

@description('Use RBAC for Key Vault auth')
param enableRbacAuthorization bool = true

@description('Enable purge protection (recommended: true for prod)')
param enablePurgeProtection bool = true

@description('Public network access (Enabled or Disabled)')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      name: skuName
      family: 'A'
    }
    enableRbacAuthorization: enableRbacAuthorization
    enablePurgeProtection: enablePurgeProtection
    publicNetworkAccess: publicNetworkAccess
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

output keyVaultId string = kv.id
output keyVaultUri string = kv.properties.vaultUri
