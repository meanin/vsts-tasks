[CmdletBinding()]
param()

Trace-VstsEnteringInvocation $MyInvocation

$connectedServiceNameSelector = Get-VstsInput -Name ConnectedServiceNameSelector -Require
$connectedServiceName = Get-VstsInput -Name ConnectedServiceName
$connectedServiceNameARM = Get-VstsInput -Name ConnectedServiceNameARM

if ($connectedServiceNameSelector -eq "ConnectedServiceNameARM")
{
    $connectedServiceName = $connectedServiceNameARM
}

$resourceGroupName=Get-VstsInput -Name ResourceGroupName -Require
$storageAccountName=Get-VstsInput -Name StorageAccountName -Require
$location=Get-VstsInput -Name Location -Require
$sku=Get-VstsInput -Name Sku -Require
$kind="Storage"
$tableName=Get-VstsInput -Name TableName -Require
    
# Initialize Azure.
Import-Module $PSScriptRoot\ps_modules\VstsAzureHelpers_
Initialize-Azure

try 
{    
    # Importing required version of azure cmdlets according to azureps installed on machine
    $azureUtility = Get-AzureUtility $connectedServiceName

    Write-Verbose -Verbose "Loading $azureUtility"
    . "$PSScriptRoot/$azureUtility"

    # Getting connection type (Certificate/UserNamePassword/SPN) used for the task
    $connectionType = Get-TypeOfConnection -connectedServiceName $connectedServiceName

    Write-Output "Get-AzureRmStorageAccount " $resourceGroupName "/" $storageAccountName
    $storageAccount=Get-AzureRmStorageAccount `
        -ResourceGroupName $resourceGroupName `
        -Name $storageAccountName `
        -ErrorAction Ignore `
        -connectionType $connectionType `
        -connectedServiceName $connectedServiceName
    if(-not $storageAccount)
    {
        Write-Output "Storage account does not exist. Creating with params: { "
        Write-Output "resourceGroupName: " $resourceGroupName ", "
        Write-Output "storageAccountName: " $storageAccountName ", "
        Write-Output "location: " $location ", "
        Write-Output "sku: " $sku " }"
        $storageAccount=New-AzureRmStorageAccount `
            -ResourceGroupName $resourceGroupName `
            -Name $storageAccountName `
            -Location $location `
            -SkuName $sku `
            -Kind $kind `
            -connectionType $connectionType `
            -connectedServiceName $connectedServiceName
    }
    Write-Output "Result: " $storageAccount
    
    if(!$tableName)
    {
        return
    }

    Write-Output "Get-AzureStorageTable " $tableName
    $table=Get-AzureStorageTable `
        -Context $storageAccount.Context `
        -DefaultProfile $context `
        -Name $tableName `
        -ErrorAction Ignore  `
        -connectionType $connectionType `
        -connectedServiceName $connectedServiceName
    if(-not $table)
    {
        Write-Output "Storage account table does not exist. Creating " $tableName
        $table=New-AzureStorageTable `
            -Name $tableName `
            -Context $storageAccount.Context `
            -connectionType $connectionType `
            -connectedServiceName $connectedServiceName
    }
    Write-Output "Result: " $table
    
} finally {
	Trace-VstsLeavingInvocation $MyInvocation
}
