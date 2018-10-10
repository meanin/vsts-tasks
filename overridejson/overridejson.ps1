[CmdletBinding()]
param(
    [string] [Parameter(Mandatory = $true)]
    $JsonPath
)

try 
{   
    #$List = Get-Content -Raw -Path $JsonPath | ConvertFrom-Json
    Get-Item Env:
    
} catch 
{
    Write-Host $_.Exception.ToString()
    throw
}
