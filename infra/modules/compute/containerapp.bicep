targetScope = 'resourceGroup'

@description('Container App name')
param containerAppName string

@description('Location')
param location string

@description('Container image (e.g. ghcr.io/org/app:tag)')
param containerImage string

@description('Managed environment ID for Container Apps')
param managedEnvId string

resource app 'Microsoft.App/containerApps@2024-03-01' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: managedEnvId
    configuration: {
      ingress: {
        external: true
        targetPort: 80
      }
    }
    template: {
      containers: [
        {
          name: 'app'
          image: containerImage
          resources: {
            cpu: 0.5
            memory: '1Gi'
          }
        }
      ]
    }
  }
}

output containerAppId string = app.id
output fqdn string = app.properties.configuration.ingress.fqdn
