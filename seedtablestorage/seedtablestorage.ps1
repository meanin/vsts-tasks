[CmdletBinding()]
param(
    [string] [Parameter(Mandatory = $true)]
    $ConnectedServiceName, 
    [string] [Parameter(Mandatory = $true)]
    $StorageAccountName,
    [string] [Parameter(Mandatory = $true)]
    $TableName,
    [string] [Parameter(Mandatory = $true)]
    $JsonPath,
    [string] [Parameter(Mandatory = $true)]
    $UpdateOnConflict
)

Install-Module -Name AzureRmStorageTable -Force -Verbose -Scope CurrentUser
try 
{   
    $ResourceGroupName = (Get-AzureRmResourceGroup).ResourceGroupName
    Write-Output "Get-AzureRmStorageAccount $ResourceGroupName/$StorageAccountName"
    $StorageAccount=Get-AzureRmStorageAccount `
        -ResourceGroupName $ResourceGroupName `
        -Name $StorageAccountName `
        -ErrorAction Ignore
    if(-not $StorageAccount)
    {
        throw "Storage account does not exist!"
    }
    else {
        Write-Output "Found: $ResourceGroupName/$StorageAccountName"
    }    

    Write-Output "Get-AzureStorageTable $TableName "
    $Table=Get-AzureStorageTable `
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

    $List = Get-Content -Raw -Path $JsonPath | ConvertFrom-Json
    foreach ($Row in $List)
    {       
        $CopyForOverride = New-Object PsObject
        $Row.psobject.Properties | % {Add-Member -MemberType NoteProperty -InputObject $CopyForOverride -Name $_.Name -Value $_.Value}
        $PartitionKey = $Row.partitionKey
        $RowKey = $Row.rowKey
        $Row.PsObject.Properties.Remove("partitionKey")
        $Row.PsObject.Properties.Remove("rowKey")
        $Property = @{}
        $Row.psobject.properties | foreach { $Property[$_.Name] = $_.Value }
        Write-Output "Adding row, partitionKey: $PartitionKey, rowKey: $RowKey"
        Write-Output "Values: $Row"   

        try 
        {
            Add-StorageTableRow `
                -Table $Table `
                -PartitionKey $PartitionKey `
                -RowKey $RowKey `
                -Property $Property                
        }
        catch 
        {
            Write-Output "Row already exists"   
            if($UpdateOnConflict -eq $true)
            {
                Write-Output "Overriding row"   
                $CopyForOverride | Add-Member -Name 'ETag' -Type NoteProperty -Value "*"
                $CopyForOverride | Update-AzureStorageTableRow -table $table
            }
            else
            {
                Write-Output "Won't override"                
            }
        }
    }
} 
catch 
{
    Write-Host $_.Exception.ToString()
    throw
}
