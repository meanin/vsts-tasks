[CmdletBinding()]
param(
    [string] [Parameter(Mandatory = $true)]
    $ConnectedServiceName, 
    [string] [Parameter(Mandatory = $true)]
    $ResourceGroupName,
    [string] [Parameter(Mandatory = $true)]
    $StorageAccountName,
    [string] [Parameter(Mandatory = $true)]
    $Sku, 
    [string]
    $Location,
    [string]
    $TableName
)
$Kind="Storage"

try 
{   
    if(-not $Location)
    {
        $Location = (Get-AzureRmResourceGroup -Name $ResourceGroupName).Location
    }
    Write-Output "Get-AzureRmStorageAccount $ResourceGroupName/$StorageAccountName"
    $StorageAccount=Get-AzureRmStorageAccount `
        -ResourceGroupName $ResourceGroupName `
        -Name $StorageAccountName `
        -ErrorAction Ignore
    if(-not $StorageAccount)
    {
        Write-Output "Storage account does not exist. Creating with params: { "
        Write-Output "ResourceGroupName: $ResourceGroupName, "
        Write-Output "StorageAccountName: $StorageAccountName, "
        Write-Output "Location: $Location, "
        Write-Output "Sku: $Sku }"
        $StorageAccount=New-AzureRmStorageAccount `
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
        -Context $StorageAccount.Context `
        -Name $TableName `
        -ErrorAction Ignore
    if(-not $table)
    {
        Write-Output "Storage account table does not exist. Creating $TableName "
        $table=New-AzureStorageTable `
            -Name $TableName `
            -Context $StorageAccount.Context
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
