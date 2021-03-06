function New-ModVariables {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$false)]
    [switch]$clear
  )
  $MSTeamsSettings = [ordered]@{
    MicrosoftTeams = ""
    AzureAD = ""
    azureadsession = ""
    msteamsession = ""
    role = ""
    Prefix = ""
    onlinepstngateway1 = ""
    onlinepstngateway2 = ""
    pstnusage = ""
    onlinevoiceroute = ""
    onlinevoiceroutingpolicy = ""
    numpatt = ".*"
    AaGuiD = "ce933385-9390-45d1-9512-c8d228074e07"
    CqGuid = "11cd3e2e-fccb-42ad-ad00-878b93575e07"
  }

  switch ($clear) {
    $true { Set-Variable -Name MSTeamsSettings -Value $MSTeamsSettings -Scope Script -Force }
    $false { New-Variable -Name MSTeamsSettings -Value $MSTeamsSettings -Scope Script -Force}
  }
}