[CmdletBinding()]
param(
    [string] [Parameter(Mandatory = $true)]
    $ConnectedServiceName, 
    [string] [Parameter(Mandatory = $true)]
    $StorageAccountName,
    [string] [Parameter(Mandatory = $true)]
    $TableName
)

try 
{   
    $ResourceGroupName = (Get-AzureRmResourceGroup).ResourceGroupName
    if(-not $Location)
    {
        $Location = (Get-AzureRmResourceGroup).Location
    }
    Write-Output "Get-AzureRmStorageAccount $ResourceGroupName/$StorageAccountName"
    $StorageAccount=Get-AzureRmStorageAccount `
        -ResourceGroupName $ResourceGroupName `
        -Name $StorageAccountName `
        -ErrorAction Ignore
    if(-not $storageAccount)
    {
        throw "Storage account does not exist!"
    }
    else {
        Write-Output "Found: $ResourceGroupName/$StorageAccountName"
    }    

    Write-Output "Get-AzureStorageTable $TableName "
    $table=Get-AzureStorageTable `
        -Context $StorageAccount.Context `
        -Name $TableName `
        -ErrorAction Ignore
    if(-not $table)
    {
        throw "Table does not exist!"
    }
    else {
        Write-Output "Found: $ResourceGroupName/$StorageAccountName/$TableName"
    }

    Write-Output "Now I want to seed table!!!!"
    
} catch 
{
    Write-Host $_.Exception.ToString()
    throw
}
