param cosmoDBAccountName string = 'toyrnd-${uniqueString(resourceGroup().id)}'
param location string = resourceGroup().location
param cosmosDBDatabaseThroughput int = 400 

var cosmosDBDatabaseName = 'FlightTest'
var cosmosDBContainerName = 'FlightTests'
var cosmosDBContainerPartitionKey = '/droneId'

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

