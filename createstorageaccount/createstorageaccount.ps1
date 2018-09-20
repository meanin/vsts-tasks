Trace-VstsEnteringInvocation $MyInvocation
Import-VstsLocStrings "$PSScriptRoot\Task.json"

try {
    $resourceGroupName=Get-VstsInput -Name resourcegroupname -Require
    $storageAccountName=Get-VstsInput -Name storageaccountname -Require
    $location=Get-VstsInput -Name location -Require
    $sku=Get-VstsInput -Name sku -Require
    $kind="Storage"
    $tableName=Get-VstsInput -Name tablename -Require
    
    $storageAccount=Get-AzureRmStorageAccount `
        -ResourceGroupName $resourceGroupName `
        -Name $storageAccountName `
        -ErrorAction Ignore
    
    if(-not $storageAccount)
    {
        $storageAccount=New-AzureRmStorageAccount `
            -ResourceGroupName $resourceGroupName `
            -Name $storageAccountName `
            -Location $location `
            -SkuName $sku `
            -Kind $kind `
            -ErrorAction Ignore
    }
    Write-Output "Get-AzureRmStorageAccount `
        -ResourceGroupName $resourceGroupName `
        -Name $storageAccountName" $storageAccount
    
    $table=Get-AzureStorageTable `
        -Context $storageAccount.Context `
        -Name $tableName `
        -ErrorAction Ignore
    
    if(-not $table)
    {
        New-AzureStorageTable `
            -Name $tableName `
            -Context $storageAccount.Context
    }
    Write-Output "Get-AzureStorageTable `
        -Context $storageAccount.Context `
        -Name $tableName" $table
} finally {
	Trace-VstsLeavingInvocation $MyInvocation
}
