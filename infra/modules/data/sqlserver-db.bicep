@description('SQL Server name')
param name string

@description('Deployment location')
param location string

@description('Administrator username')
param adminLogin string

@description('Administrator password')
@secure()
param adminPassword string

@description('SQL database name')
param databaseName string

resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: name
  location: location
  properties: {
    administratorLogin: adminLogin
    administratorLoginPassword: adminPassword
    publicNetworkAccess: 'Disabled' // force private endpoint access only
    minimalTlsVersion: '1.2'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-05-01-preview' = {
  name: databaseName
  parent: sqlServer
  properties: {
    sku: {
      name: 'Basic'
      tier: 'Basic'
    }
  }
}

@description('SQL Server ID')
output sqlServerId string = sqlServer.id

@description('SQL Database ID')
output sqlDatabaseId string = sqlDatabase.id
