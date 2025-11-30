@description('Global resource prefix (ex: prja01, mwcorp01)')
param prefix string

@description('Resource short type (ex: stg, sql, kv, law, appi)')
param resourceType string

@description('Environment (dev/test/prod)')
param environment string

// CAF-compliant, globally unique, lowercase
var uniqueSuffix = toLower(substring(uniqueString(prefix, resourceType, environment), 0, 5))

output name string = toLower('${prefix}-${resourceType}-${environment}-${uniqueSuffix}')
