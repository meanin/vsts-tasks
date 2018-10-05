[CmdletBinding()]
param(
    [string] [Parameter(Mandatory = $true)]
    $ConnectedServiceName, 
    [string] [Parameter(Mandatory = $true)]
    $StorageAccountName, 
    [string] [Parameter(Mandatory = $true)]
    $Location,
    [string] [Parameter(Mandatory = $true)]
    $Sku,
    [string]$TableName
)
$Kind="Storage"

try 
{   
    $ResourceGroupName = (Get-AzureRmResourceGroup).ResourceGroupName
    Write-Output "Get-AzureRmStorageAccount $ResourceGroupName/$StorageAccountName"
    $storageAccount=Get-AzureRmStorageAccount `
        -ResourceGroupName $ResourceGroupName `
        -Name $StorageAccountName `
        -ErrorAction Ignore
    if(-not $storageAccount)
    {
        Write-Output "Storage account does not exist. Creating with params: { "
        Write-Output "ResourceGroupName: $ResourceGroupName, "
        Write-Output "StorageAccountName: $StorageAccountName, "
        Write-Output "Location: $Location, "
        Write-Output "Sku: $Sku }"
        $storageAccount=New-AzureRmStorageAccount `
            -ResourceGroupName $ResourceGroupName `
            -Name $StorageAccountName `
            -Location $Location `
            -SkuName $Sku `
            -Kind $Kind
        Write-Output "Created: $ResourceGroupName/$StorageAccountName"
    }
    else {
        Write-Output "Storage account already exists"
    }
    
    if(!$TableName)
    {
        return
    }

    Write-Output "Get-AzureStorageTable $TableName "
    $table=Get-AzureStorageTable `
        -Context $storageAccount.Context `
        -Name $TableName `
        -ErrorAction Ignore
    if(-not $table)
    {
        Write-Output "Storage account table does not exist. Creating $TableName "
        $table=New-AzureStorageTable `
            -Name $TableName `
            -Context $storageAccount.Context
        Write-Output "Created: $ResourceGroupName/$StorageAccountName/$TableName"
    }
    else {
        Write-Output "Table already exists"
    }
    
} catch 
{
    Write-Host $_.Exception.ToString()
    throw
}
