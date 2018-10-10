# vsts-tasks

I want to achieve here a few tasks which let me to create and manage a Storage Account on an Azure DevOps' Release Pipeline.

## How to use

1. Install the task in your Azure Devops account by navigating to the marketplace and click install. Select the Azure Devops account where the task will be deployed to.

2. Add the task to your release by clicking in your release on add a task. Click the Add button on the Create Storage Account task.

3. Configure task.

4. On release run the storage account and/or table will be created if not exist.

### 1. Create Storage Account
Provides a possibility to create storage account and a single table on a Release pipeline, before application deployment.

#### Configure the task.
![alt tag](https://raw.githubusercontent.com/meanin/vsts-tasks/master/screenshots/createstorageaccount.png)
* Select an AzureRM subscription connection - use service principal scoped to one resource group
* Set the storage account name, if not exist it will be created
* Select a location from a dropdown list, if not selected will be inherited from resource group
* Select Sku
* Set the table name if you want to create a table in newly created storage account

### 2. Add Storage Account's connection string to Key Vault
Want to be sure that connection string to your storage account is securely stored in key vault? This task will help.

#### Configure the task.
![alt tag](https://raw.githubusercontent.com/meanin/vsts-tasks/master/screenshots/connectionstringtokeyvault.png)
* Select an AzureRM subscription connection - use service principal scoped to one resource group
* Set the storage account name, which connection string you want to store
* Set key vault name, if not exist it will be created
* Set key name
* Select a location from a dropdown list, if not selected will be inherited from resource group

### 3. Seed Table Storage from given json file
Enable seeding table storage from a given json file. File should look like below:
```
[
    {
        "PartitionKey": "Partition1",
        "RowKey": "SomeGuid1",
        "CustomColumn": "Values1"
        ...
    },
    {
        "PartitionKey": "Partition2",
        "RowKey": "SomeGuid2",
        "CustomColumn": "Values2"
        ...
    }
    ...
]
```
Task support flat key/value list, only.

#### Configure the task.
![alt tag](https://raw.githubusercontent.com/meanin/vsts-tasks/master/screenshots/seedtablestorage.png)
* Select an AzureRM subscription connection - use service principal scoped to one resource group
* Set the storage account name, which you want to seed
* Set the table name, which you want to seed
* Select Json File path, it should be made of a list of flat key / value objects, PartitionKey and RowKey are required
* Set Update Row On Conflict if row should be override

### 4. Override json config file with release variables
Based on existing environment variables on release agent, overwrite json file properties with the same name. Setting prefix is optional. Environment variables on an Azure DevOps are set on configuring release in a variables tab, or linked from variable group.

#### Configure the task.
![alt tag](https://raw.githubusercontent.com/meanin/vsts-tasks/master/screenshots/overridejson.png)
* Select Json File path, it should be made of a list of flat key / value objects, PartitionKey and RowKey are required
* Optionally set prefix by which variables will be selected
