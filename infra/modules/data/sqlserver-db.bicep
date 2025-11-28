@description('Location for SQL Server')
param location string

@description('Environment name')
param environment string

@description('Resource name prefix')
param resourceNamePrefix string

@description('Tags to apply')
param tags object

@description('Subnet for private endpoint (not used directly here)')
param vnetSubnetId string

@secure()
@description('SQL admin password')
param administratorLoginPassword string

// Reference to avoid unused param warning
var _unusedSubnetReference = vnetSubnetId

var sqlServerName = toLower('${resourceNamePrefix}-sql-${environment}')
var dbName = 'appdb'

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sqlServerName
  location: location
  tags: tags
  properties: {
    administratorLogin: 'sqladminuser'
    administratorLoginPassword: administratorLoginPassword
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
  }
}

resource sqlDb 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  name: dbName
  parent: sqlServer
  location: location
  sku: {
    name: 'GP_Gen5_2'
    tier: 'GeneralPurpose'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
  }
}

output sqlServerId string = sqlServer.id
output sqlServerName string = sqlServer.name
output databaseName string = sqlDb.name