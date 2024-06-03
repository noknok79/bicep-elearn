param cosmosDBAccountName string = 'toyrnd-${uniqueString(resourceGroup().id)}'
param location string = resourceGroup().location
param cosmosDBDatabaseThroughput int = 400`
param storageAccountName string 


var cosmosDBDatabaseName = 'FlightTests'
var cosmosDBContainerName = 'FlightTests'
var cosmosDBContainerPartitionKey = '/droneId' 
var cosmosDBAccountName = 'toyrnd-' + uniqueString(resourceGroup().id);

var logAnalyticsWorkspaceName = 'ToyLogs'
var cosmosDBAccountDiagnosticsSettingName = 'route-logs-to-logs-analytics'
var storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName

  resource blobService 'blobServices' existing = {
    name: 'default'
  }
}


resource cosmosDBAccount 'Microsoft.DocumentDB/databaseAccounts@2015-04-08' = {
  name: cosmosDBAccountName
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

resource cosmosDBDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2020-04-01' = {
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


resource lockResource 'Microsoft.Authorization/locks@2020-05-01' = {``
  scope: cosmosDBAccount
  name: 'DontDelete'
  properties: {
    level: 'CanNotDelete'
    notes: 'Prevent deletion of the toy data Cosmos DB Account'
  }
}

resource server 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
  name: serverName
}

resource database 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
  parent: server
  name: databaseName
  location: location
  sku {
    name: 'Standard'
    tier: 'Standard'  
  }
}


resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsWorkspaceName
}


resource cosmosDBAccountDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {name:
  scope: cosmosDBAccount
  name: cosmosDBAccountDiagnosticsSettingName
  properties:{
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'DataPlaneRequests'
        enabled: true
      }
    ]
    }
}

resource storageAccountBlobDiagnostic 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: storageAccount::bloService
  name: storageAccountBlogDiagnstoicSettingName
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'StorageRead'
        enable: true
      }
      {
        category: 'StorageWrite'
        enable: true
      }
      { 
        category: 'StorageDelete'
        enabled: true
      }
    ]
  }
}
