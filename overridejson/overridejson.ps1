[CmdletBinding()]
param()

Trace-VstsEnteringInvocation $MyInvocation
$JsonPath=Get-VstsInput -Name JsonPath
$Prefix=Get-VstsInput -Name Prefix

try 
{   
    Write-Output "Reading environment variables based on prefix '$Prefix'"
    $EnvironmentVariables = @{}
    foreach($Var in Get-VstsTaskVariableInfo)
    {
        if([string]::IsNullOrWhitespace($Prefix))
        {
            $EnvironmentVariables.Add($Var.Name, $Var.Value)
        }
        if([string]::IsNullOrWhitespace($Prefix) -eq $false -and $Var.Name.StartsWith($Prefix))
        {
            $EnvironmentVariables.Add($Var.Name.Replace($Prefix, ""), $Var.Value)
        }
    }

    Write-Output "Reading $JsonPath file"
    $Json = @{}
    foreach($Property in $(Get-Content -Raw -Path $JsonPath | ConvertFrom-Json).psobject.properties)
    { 
        if($EnvironmentVariables.ContainsKey($Property.Name))
        {
            $Json[$Property.Name] = $EnvironmentVariables[$Property.Name]
        }
        else
        {
            $Json[$Property.Name] = $Property.Value 
        }
    }
    
    Write-Output "Overriding $JsonPath file"    
    $Json | ConvertTo-Json -Depth 1 | Out-File -FilePath $JsonPath
} 
finally 
{
    Trace-VstsLeavingInvocation $MyInvocation
}
