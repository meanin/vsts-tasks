[CmdletBinding()]
param(
    [string] [Parameter(Mandatory = $true)]
    $ConnectedServiceName, 
    [string] [Parameter(Mandatory = $true)]
    $StorageAccountName, 
    [string] [Parameter(Mandatory = $true)]
    $KeyVaultName,
    [string] [Parameter(Mandatory = $true)]
    $KeyVaultKeyName,
    [string]
    $Location
)

try 
{   
    $ResourceGroupName = (Get-AzureRmResourceGroup).ResourceGroupName
    if(-not $Location)
    {
        $Location = (Get-AzureRmResourceGroup).Location
    }
    Write-Output "Get-AzureRmStorageAccount $ResourceGroupName/$StorageAccountName"
    $storageAccount = Get-AzureRmStorageAccount `
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

    Write-Output "Get-AzureRmKeyVault $ResourceGroupName/$KeyVaultName"
    $KeyVault = Get-AzureRmKeyVault `
        -ResourceGroupName $ResourceGroupName `
        -VaultName $KeyVaultName `
        -ErrorAction Ignore
    if(-not $KeyVault)
    {
        Write-Output "Key Vault does not exist. Creating with params: { "
        Write-Output "ResourceGroupName: $ResourceGroupName, "
        Write-Output "KeyVaultName: $KeyVaultName, "
        Write-Output "Location: $Location }"
        $KeyVault=New-AzureRmKeyVault `
            -VaultName $KeyVaultName `
            -ResourceGroupName $ResourceGroupName `
            -EnabledForDeployment `
            -Location $Location
        Write-Output "Created: $ResourceGroupName/$KeyVaultName"
    }
    else {
        Write-Output "Key Vault already exists"
    }

    Set-AzureRmKeyVaultAccessPolicy `
    -VaultName $KeyVaultName `
    -ResourceGroupName $ResourceGroupName `
    -ServicePrincipalName (Get-AzureRmContext).Account `
    -PermissionsToKeys create,delete,list `
    -PermissionsToSecrets set,delete,list `
    -ErrorAction Ignore
    
    Add-AzureKeyVaultKey `
        -VaultName $KeyVaultName `
        -Name $KeyVaultKeyName `
        -Destination Software `
        -ErrorAction Ignore
    
    $StorageAccountKey = Get-AzureRmStorageAccountKey -ResourceGroupName $ResourceGroupName -AccountName $StorageAccountName
    $Secret = ConvertTo-SecureString -String $StorageAccountKey -AsPlainText -Force
    Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $KeyVaultKeyName -SecretValue $Secret    
} catch 
{
    Write-Host $_.Exception.ToString()
    throw
}
