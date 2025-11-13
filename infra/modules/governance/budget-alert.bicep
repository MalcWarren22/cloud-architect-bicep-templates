targetScope = 'subscription'

@description('Budget name')
param budgetName string

@description('Amount in currency')
param amount float = 100.0

@description('Currency code')
param currency string = 'USD'

@description('Contact emails')
param emails array

resource budget 'Microsoft.Consumption/budgets@2023-05-01' = {
  name: budgetName
  properties: {
    category: 'Cost'
    amount: amount
    timeGrain: 'Monthly'
    timePeriod: {
      startDate: dateTimeUtcNow()
      endDate: dateTimeAdd(dateTimeUtcNow(), 'P1Y')
    }
    notifications: {
      Actual_80: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 80
        contactEmails: emails
      }
    }
  }
}
