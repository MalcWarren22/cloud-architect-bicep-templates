targetScope = 'resourceGroup'

@description('Environment name (dev/test/prod)')
param environment string

@description('Deployment location')
param location string = resourceGroup().location

@description('Optional monthly cost budget amount in USD for this resource group (0 = no budget)')
param monthlyBudgetAmount int = 0

@description('Optional email address to receive budget alerts')
param budgetContactEmail string = ''

@description('Optional policy definition ID to assign at the resource group scope')
param policyDefinitionId string = ''

@description('Optional policy assignment name (if policyDefinitionId is provided)')
param policyAssignmentName string = 'rg-policy'

@description('Optional policy parameters object')
param policyParameters object = {}

// ------------------------
// Observability: Log Analytics + App Insights
// ------------------------
module logAnalytics './modules/observability/log-analytics.bicep' = {
  name: 'la-${environment}'
  params: {
    name: 'la-${environment}'
    location: location
  }
}

module appInsights './modules/observability/app-insights.bicep' = {
  name: 'appi-${environment}'
  params: {
    name: 'appi-${environment}'
    location: location
    workspaceId: logAnalytics.outputs.workspaceId
  }
}

// ------------------------
// Hub VNet
// ------------------------
module hubVnet './modules/networking/vnet.bicep' = {
  name: 'hub-vnet-${environment}'
  params: {
    name: 'hub-vnet-${environment}'
    addressSpace: '10.0.0.0/16'
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        addressPrefix: '10.0.0.0/24'
      }
      {
        name: 'shared-services'
        addressPrefix: '10.0.1.0/24'
      }
    ]
  }
}

// ------------------------
// Spoke (App) VNet
// ------------------------
module appVnet './modules/networking/vnet.bicep' = {
  name: 'app-vnet-${environment}'
  params: {
    name: 'app-vnet-${environment}'
    addressSpace: '10.10.0.0/16'
    subnets: [
      {
        name: 'app-subnet'
        addressPrefix: '10.10.0.0/24'
      }
      {
        name: 'data-subnet'
        addressPrefix: '10.10.1.0/24'
      }
    ]
  }
}

// Convenience vars for subnet IDs
var appSubnetId = appVnet.outputs.subnetIds[0]
var dataSubnetId = appVnet.outputs.subnetIds[1]

// ------------------------
// NSG for app-subnet
// ------------------------
module appNsg './modules/networking/nsg.bicep' = {
  name: 'app-nsg-${environment}'
  params: {
    name: 'app-nsg-${environment}'
    rules: [
      {
        name: 'Allow-HTTP'
        description: 'Allow inbound HTTP from anywhere'
        protocol: 'Tcp'
        sourcePortRange: '*'
        destinationPortRange: '80'
        sourceAddressPrefix: '*'
        destinationAddressPrefix: '*'
        access: 'Allow'
        priority: 200
        direction: 'Inbound'
      }
      {
        name: 'Allow-HTTPS'
        description: 'Allow inbound HTTPS from anywhere'
        protocol: 'Tcp'
        sourcePortRange: '*'
        destinationPortRange: '443'
        sourceAddressPrefix: '*'
        destinationAddressPrefix: '*'
        access: 'Allow'
        priority: 210
        direction: 'Inbound'
      }
    ]
  }
}

// Attach NSG to app-subnet
module appSubnetNsg './modules/networking/subnet-nsg-association.bicep' = {
  name: 'app-subnet-nsg-assoc-${environment}'
  params: {
    subnetId: appSubnetId
    nsgId: appNsg.outputs.nsgId
  }
}

// ------------------------
// Hub <-> Spoke Peering
// ------------------------
module hubAppPeering './modules/networking/vnet-peering.bicep' = {
  name: 'hub-app-peering-${environment}'
  params: {
    vnetAId: hubVnet.outputs.vnetId
    vnetBId: appVnet.outputs.vnetId
    nameAToB: 'hub-to-app-${environment}'
    nameBToA: 'app-to-hub-${environment}'
  }
}

// ------------------------
// Security: Key Vault + Private Endpoint
// ------------------------
module keyVault './modules/security/keyvault.bicep' = {
  name: 'kv-${environment}'
  params: {
    name: 'kv-${environment}'
    location: location
    logAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
  }
}

// Private endpoint for Key Vault in data subnet
module keyVaultPrivateEndpoint './modules/security/private-endpoint.bicep' = {
  name: 'kv-pe-${environment}'
  params: {
    name: 'kv-pe-${environment}'
    targetResourceId: keyVault.outputs.keyVaultId
    subnetId: dataSubnetId
    groupId: 'vault'
    enablePrivateDns: false       // will wire to Private DNS module later
    privateDnsZoneId: ''
  }
}

// ------------------------
// Data: Storage Account + Private Endpoint
// ------------------------
module storage './modules/data/storage-account.bicep' = {
  name: 'st${environment}'
  params: {
    // storage account names must be globally unique and lowercase, 3–24 chars
    name: 'st${environment}001'
    location: location
  }
}

module storagePrivateEndpoint './modules/security/private-endpoint.bicep' = {
  name: 'st-pe-${environment}'
  params: {
    name: 'st-pe-${environment}'
    targetResourceId: storage.outputs.storageId
    subnetId: dataSubnetId
    groupId: 'blob'
    enablePrivateDns: false
    privateDnsZoneId: ''
  }
}

// ------------------------
// Data: SQL Server + Database + Private Endpoint
// ------------------------
module sql './modules/data/sqlserver-db.bicep' = {
  name: 'sql-${environment}'
  params: {
    name: 'sql-${environment}'
    location: location
    adminLogin: 'sqladminuser'
    adminPassword: 'P@ssw0rd123!!!' // TODO: move to Key Vault/param in real use
    databaseName: 'appdb'
  }
}

module sqlPrivateEndpoint './modules/security/private-endpoint.bicep' = {
  name: 'sql-pe-${environment}'
  params: {
    name: 'sql-pe-${environment}'
    targetResourceId: sql.outputs.sqlServerId
    subnetId: dataSubnetId
    groupId: 'sqlServer'
    enablePrivateDns: false
    privateDnsZoneId: ''
  }
}

// ------------------------
// Compute: App Service Web API in app subnet
// ------------------------
module webApi './modules/compute/appservice-webapi.bicep' = {
  name: 'webapi-${environment}'
  params: {
    name: 'webapi-${environment}'
    location: location
    subnetId: appSubnetId
    skuName: 'B1'
    skuTier: 'Basic'
    logAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
    appSettings: {
      'ASPNETCORE_ENVIRONMENT': environment
      'KEYVAULT_URI': keyVault.outputs.keyVaultUri

      // Data layer settings
      'STORAGE_BLOB_URL': storage.outputs.blobEndpoint
      'SQL_SERVER_ID': sql.outputs.sqlServerId
      'SQL_DATABASE_ID': sql.outputs.sqlDatabaseId

      // Observability settings
      'APPLICATIONINSIGHTS_CONNECTION_STRING': appInsights.outputs.appInsightsConnectionString
      'APPINSIGHTS_INSTRUMENTATIONKEY': appInsights.outputs.appInsightsInstrumentationKey
    }
  }
}

// ------------------------
// RBAC: grant Web App MSI access to Key Vault
// ------------------------
module keyVaultRbac './modules/security/rbac-role-assignments.bicep' = if (!empty(webApi.outputs.principalId)) {
  name: 'kv-rbac-${environment}'
  params: {
    assignments: [
      {
        scope: keyVault.outputs.keyVaultId
        roleDefinitionId: subscriptionResourceId(
          'Microsoft.Authorization/roleDefinitions',
          '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User
        )
        principalId: webApi.outputs.principalId
        principalType: 'ServicePrincipal'
      }
    ]
  }
}

// ------------------------
// Governance: Budget
// ------------------------
module monthlyBudget './modules/governance/budget.bicep' = if (monthlyBudgetAmount > 0 && !empty(budgetContactEmail)) {
  name: 'budget-${environment}'
  params: {
    name: 'rg-budget-${environment}'
    amount: monthlyBudgetAmount
    timeGrain: 'Monthly'
    // long-running budget period; can be adjusted as needed
    startDate: '2025-01-01'
    endDate: '2099-12-31'
    contactEmails: [
      budgetContactEmail
    ]
  }
}

// ------------------------
// Governance: Policy Assignment (optional)
// ------------------------
module rgPolicy './modules/governance/policy-assignment.bicep' = if (!empty(policyDefinitionId)) {
  name: 'policy-${environment}'
  params: {
    name: policyAssignmentName
    policyDefinitionId: policyDefinitionId
    parameters: policyParameters
  }
}

// ------------------------
// Useful outputs
// ------------------------
output hubVnetId string = hubVnet.outputs.vnetId
output appVnetId string = appVnet.outputs.vnetId
output appSubnetId string = appSubnetId
output dataSubnetId string = dataSubnetId

output keyVaultId string = keyVault.outputs.keyVaultId
output keyVaultUri string = keyVault.outputs.keyVaultUri

output webApiId string = webApi.outputs.webAppId
output webApiHostname string = webApi.outputs.hostname

output storageId string = storage.outputs.storageId
output storageBlobUrl string = storage.outputs.blobEndpoint

output sqlServerId string = sql.outputs.sqlServerId
output sqlDatabaseId string = sql.outputs.sqlDatabaseId

output logAnalyticsWorkspaceId string = logAnalytics.outputs.workspaceId
output appInsightsId string = appInsights.outputs.appInsightsId
