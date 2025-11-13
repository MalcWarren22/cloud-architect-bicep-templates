targetScope = 'resourceGroup'

@description('Environment name (dev, test, prod, etc.)')
param environmentName string

@description('Azure region')
param location string = resourceGroup().location

@description('Name prefix for resources')
param namePrefix string = 'corp'

@description('Address space for the spoke VNet')
param vnetAddressSpace string = '10.70.0.0/16'

@description('Container image to run')
param containerImage string = 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'

var vnetName = '${namePrefix}-${environmentName}-ca-vnet'
var envName = '${namePrefix}-${environmentName}-ca-env'
var appName = '${namePrefix}-${environmentName}-ca'

//
// 1) Networking – Spoke VNet (optional for future VNet integration)
//
module vnetSpoke '../modules/networking/vnet-spoke.bicep' = {
  name: 'caVnetSpoke'
  params: {
    vnetName: vnetName
    location: location
    addressSpace: vnetAddressSpace
    subnets: [
      {
        name: 'apps'
        addressPrefix: '10.70.1.0/24'
      }
    ]
  }
}

//
// 2) Managed Environment for Container Apps
//
resource managedEnv 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: envName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: ''
        sharedKey: ''
      }
    }
    // For simplicity, no VNet integration here.
    // You can add vnetConfiguration later using vnetSpoke outputs.
  }
}

//
// 3) Container App
//
module containerApp '../modules/compute/containerapp.bicep' = {
  name: 'containerApp'
  params: {
    containerAppName: appName
    location: location
    containerImage: containerImage
    managedEnvId: managedEnv.id
  }
}

output vnetId string = vnetSpoke.outputs.vnetId
output managedEnvironmentId string = managedEnv.id
output containerAppId string = containerApp.outputs.containerAppId
output containerAppFqdn string = containerApp.outputs.fqdn
