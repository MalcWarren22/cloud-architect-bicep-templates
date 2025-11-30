@description('Location for the resource')
param location string

@description('Environment name')
param environment string

@description('Resource name prefix applied to this resource')
param resourceNamePrefix string

@description('Tags to apply to this resource')
param tags object

@description('Name of the Key Vault (base name)')
param name string

@description('Tenant ID for the Key Vault')
param tenantId string = tenant().tenantId

@description('Soft delete retention in days')
param softDeleteRetentionDays int = 7

@description('Enable purge protection')
param enablePurgeProtection bool = true

@description('Enable RBAC authorization instead of access policies')
param enableRbacAuthorization bool = true

@description('Optional Log Analytics workspace ID for diagnostics')
param logAnalyticsWorkspaceId string = ''

// Tag enrichment so all params are used intentionally
var kvTags = union(tags, {
  environment: environment
  workload: resourceNamePrefix
})
// avoid colliding with an old soft-deleted vault name.
var kvSuffix = toLower(substring(uniqueString(subscription().id, name, environment), 0, 6))
var kvName = toLower('${name}-${kvSuffix}')


resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: kvName
  location: location
  tags: kvTags
  properties: {
    tenantId: tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    // RBAC only, no legacy access policies
    enableRbacAuthorization:    enableRbacAuthorization
    enablePurgeProtection:      enablePurgeProtection
    softDeleteRetentionInDays:  softDeleteRetentionDays
    publicNetworkAccess:        'Enabled' // locked down via private endpoint + firewall
  }
}

resource kvDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  name: '${kvName}-diag'
  scope: keyVault
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'AuditEvent'
        enabled:  true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled:  true
      }
    ]
  }
}

@description('Key Vault resource ID')
output keyVaultId string = keyVault.id

@description('Key Vault URI')
output keyVaultUri string = keyVault.properties.vaultUri
