param cosmoDBAccountName string = 'toyrnd-${uniqueString(resourceGroup().id)}'
param location string = resourceGroup().location
param cosmosDBDatabaseThroughput int = 400 
param storageAccountName string

var cosmosDBDatabaseName = 'FlightTest'
var cosmosDBContainerName = 'FlightTests'
var cosmosDBContainerPartitionKey = '/droneId'
var logAnalyticWorkspaceName = 'ToyLogs'
var cosmosDBAccountDiagnosticSettingsName = 'route-logs-to-log-analytics'
var storageAccountBlobDiagnosticsSettingName = 'route-logs-to-log-analytics'

resource cosmosDBAccount 'Microsoft.DocumentDB/databaseAccounts@2015-04-08' = { 
  name: cosmoDBAccountName
  location: location
  properties: { 
    databaseAccountOfferType: 'Standard'
    locations: [
      { 
        locationName: location
      }
    ]
  }
}

resource cosmosDBDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-05-15' = { 
  parent: cosmosDBAccount
  name: cosmosDBDatabaseName
  properties: { 
    resource: { 
      id: cosmosDBDatabaseName
    }
    options: { 
      throughput: cosmosDBDatabaseThroughput
    }
  }
  resource container 'containers' = {
    name: cosmosDBContainerName
    properties: { 
      resource: { 
        id: cosmosDBContainerName
        partitionKey: { 
          kind: 'Hash'
          paths: [ 
            cosmosDBContainerPartitionKey
          ]
        }
      }
      options: {}
    }
  }
}

resource logAnalyticWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = { 
  name: logAnalyticWorkspaceName
}

resource cosmosDBAccountDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = { 
  scope: cosmosDBAccount
  name: cosmosDBAccountDiagnosticSettingsName
  properties: { 
    workspaceId: logAnalyticWorkspace.id
    logs: [ 
      { 
        category: 'DataPlaneRequests' 
        enabled: true  
      }
    ]
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = { 
  name: storageAccountName

  resource blobService 'blobServices' existing = { 
    name: 'default'
  }
}

resource storageAccountBlobDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = { 
  scope: storageAccount::blobService
  name: storageAccountBlobDiagnosticsSettingName
  properties: { 
    workspaceId: logAnalyticWorkspace.id
    logs: [
      { 
        category: 'StorageRead'
        enabled: true
      }
      { 
        category: 'StorageWrite'
        enabled: true
      }
      { 
        category: 'StorageDelete'
        enabled: true
      }
    ]
  }
}
