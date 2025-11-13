targetScope = 'resourceGroup'

@description('SQL server name')
param sqlServerName string

@description('SQL admin login')
param administratorLogin string

@secure()
@description('SQL admin password')
param administratorLoginPassword string

@description('SQL database name')
param databaseName string

@description('Location')
param location string

resource sqlServer 'Microsoft.Sql/servers@2023-08-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    publicNetworkAccess: 'Disabled'
  }
}

resource database 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
  name: '${sqlServer.name}/${databaseName}'
  location: location
  properties: {
    readScale: 'Disabled'
  }
  sku: {
    name: 'GP_S_Gen5_2'
    tier: 'GeneralPurpose'
  }
}

output sqlServerId string = sqlServer.id
output databaseId string = database.id
