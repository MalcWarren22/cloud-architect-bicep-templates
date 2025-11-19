targetScope = 'resourceGroup'

@description('Name of the budget')
param name string

@description('Budget amount in USD')
param amount int

@description('Time grain for the budget (Monthly, Quarterly, Annually)')
param timeGrain string = 'Monthly'

@description('Start date for the budget period (YYYY-MM-DD)')
param startDate string

@description('End date for the budget period (YYYY-MM-DD)')
param endDate string

@description('Contact emails for budget alerts')
param contactEmails array

resource budget 'Microsoft.Consumption/budgets@2023-05-01' = {
  name: name
  properties: {
    category: 'Cost'
    amount: amount
    timeGrain: timeGrain
    timePeriod: {
      startDate: startDate
      endDate: endDate
    }
    notifications: {
      ActualCostThreshold90: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 90
        contactEmails: contactEmails
      }
    }
  }
}

@description('Budget resource ID')
output budgetId string = budget.id
