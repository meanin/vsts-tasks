Trace-VstsEnteringInvocation $MyInvocation
Import-VstsLocStrings "$PSScriptRoot\Task.json"

try {
    $resourceGroupName=Get-VstsInput -Name resourcegroupname -Require
    $storageAccountName=Get-VstsInput -Name storageaccountname -Require
    $location=Get-VstsInput -Name location -Require
    $sku=Get-VstsInput -Name sku -Require
    $kind="Storage"
    $tableName=Get-VstsInput -Name tablename -Require
    
    # Initialize Azure.
    Import-Module $PSScriptRoot\ps_modules\VstsAzureHelpers_
    Initialize-Azure
    
    Write-Output "Get-AzureRmStorageAccount " $resourceGroupName "/" $storageAccountName
    $storageAccount=Get-AzureRmStorageAccount `
        -ResourceGroupName $resourceGroupName `
        -Name $storageAccountName `
        -ErrorAction Ignore    
    if(-not $storageAccount)
    {
        Write-Output "Storage account does not exist. Creating with params: { "
        Write-Output "resourceGroupName: " $resourceGroupName ", "
        Write-Output "storageAccountName: " $storageAccountName ", "
        Write-Output "location: " $location ", "
        Write-Output "sku: " $sku ", "
        $storageAccount=New-AzureRmStorageAccount `
            -ResourceGroupName $resourceGroupName `
            -Name $storageAccountName `
            -Location $location `
            -SkuName $sku `
            -Kind $kind
    }
    Write-Output "Result: " $storageAccount
    
    Write-Output "Get-AzureStorageTable " $tableName
    $table=Get-AzureStorageTable `
        -Context $storageAccount.Context `
        -DefaultProfile $context `
        -Name $tableName `
        -ErrorAction Ignore 
    if(-not $table)
    {
        Write-Output "Storage account table does not exist. Creating " $tableName
        $table=New-AzureStorageTable `
            -Name $tableName `
            -Context $storageAccount.Context
    }
    Write-Output "Result: " $table
    
} finally {
	Trace-VstsLeavingInvocation $MyInvocation
}
