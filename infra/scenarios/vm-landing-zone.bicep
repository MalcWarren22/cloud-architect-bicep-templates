targetScope = 'resourceGroup'

@description('Environment name (dev, test, prod, etc.)')
param environmentName string

@description('Azure region')
param location string = resourceGroup().location

@description('Name prefix for resources')
param namePrefix string = 'corp'

@description('Address space for the spoke VNet')
param vnetAddressSpace string = '10.60.0.0/16'

@description('Admin username for the VM')
param vmAdminUsername string = 'azureuser'

@secure()
@description('Admin password for the VM (use Key Vault in real life)')
param vmAdminPassword string

@description('Whether to allocate a public IP for the VM')
param createPublicIp bool = true

var vnetName = '${namePrefix}-${environmentName}-vm-vnet'
var lawName = '${namePrefix}-${environmentName}-vm-law'
var vmName = '${namePrefix}-${environmentName}-vm'
var keyVaultName = toLower('${namePrefix}-${environmentName}-vm-kv')
var storageAccountName = toLower(replace('${namePrefix}${environmentName}vmstore', '-', ''))

//
// 1) Networking – Spoke VNet for VM
//
module vnetSpoke '../modules/networking/vnet-spoke.bicep' = {
  name: 'vmVnetSpoke'
  params: {
    vnetName: vnetName
    location: location
    addressSpace: vnetAddressSpace
    subnets: [
      {
        name: 'vm'
        addressPrefix: '10.60.1.0/24'
      }
      {
        name: 'mgmt'
        addressPrefix: '10.60.2.0/24'
      }
    ]
  }
}

var vmSubnetId = vnetSpoke.outputs.subnetIds[0]

//
// 2) Monitoring – Log Analytics
//
module monitoring '../modules/observability/monitoring-core.bicep' = {
  name: 'vmMonitoringCore'
  params: {
    lawName: lawName
    location: location
    appInsightsName: '${vmName}-ai'
  }
}

//
// 3) Security – Key Vault
//
module kv '../modules/security/keyvault.bicep' = {
  name: 'vmKeyVault'
  params: {
    keyVaultName: keyVaultName
    location: location
    skuName: 'standard'
  }
}

//
// 4) Data – Storage Account (for diagnostics/files/etc.)
//
module storage '../modules/data/storage-account.bicep' = {
  name: 'vmStorageAccount'
  params: {
    storageAccountName: storageAccountName
    location: location
  }
}

//
// 5) Compute – Linux VM
//
module vm '../modules/compute/vm-linux.bicep' = {
  name: 'linuxVm'
  params: {
    vmName: vmName
    location: location
    adminUsername: vmAdminUsername
    adminPassword: vmAdminPassword
    subnetId: vmSubnetId
    createPublicIp: createPublicIp
  }
}

output vnetId string = vnetSpoke.outputs.vnetId
output vmId string = vm.outputs.vmId
output vmPublicIp string = vm.outputs.publicIpAddress
output keyVaultUri string = kv.outputs.keyVaultUri
output logAnalyticsWorkspaceId string = monitoring.outputs.lawId
output storageAccountId string = storage.outputs.storageAccountId
