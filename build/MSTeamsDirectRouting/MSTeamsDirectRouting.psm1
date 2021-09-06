function Enable-TdrResourceAccount {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
    [string]$Username,
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=1)]
    [string]$DDI
  )
  $resourceAccount = Get-CsOnlineApplicationInstance -Identity $username
  if($resourceAccount) {
    Test-DdiFormat $DDI
    Set-CsOnlineApplicationInstance -Identity $Username -OnpremPhoneNumber $DDI
  } else {
    Set-OutputColour "Red" "$username does not exist yet, please create it and assign the appropriate license first"
  }  
}
function New-TdrResourceAccount {
  [CmdletBinding()]
  [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
  [string]$Username,
  [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=1)]
  [string]$displayName,
  [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=2)]
  [ValidateSet("Queue", "AA")]
  [string]$type
  switch ( $type ) {
      "Queue" { $type = $MSTeamsSettings.CqGuid    }
      "AA" { $type = $MSTeamsSettings.AaGuid    }
  }
  New-CsOnlineApplicationInstance -UserPrincipalName $Username -ApplicationId $type -DisplayName "$displayName"
}
function New-TdrRoutingSetup {
  Test-ConnectionStatus MicrosoftTeams
  Set-ModVariables
  $OnlinePstnGateway = if($MSTeamsSettings.onlinepstngateway2){$MSTeamsSettings.onlinepstngateway1 + ", " + $MSTeamsSettings.onlinepstngateway2} else {$MSTeamsSettings.onlinepstngateway1}
  Set-CsOnlinePstnUsage -identity Global -Usage @{Add=$pstnusage}
  New-CsOnlineVoiceRoute -identity $MSTeamsSettings.onlinevoiceroute -NumberPattern $MSTeamsSettings.numpatt -OnlinePstnGatewayList = $OnlinePstnGateway -priority 1 -OnlinePstnUsages $MSTeamsSettings.pstnusage
  New-CsOnlineVoiceRoutingPolicy $MSTeamsSettings.onlinevoiceroutingpolicy -OnlinePstnUsages $MSTeamsSettings.pstnusage
  Set-CsTeamsCallingPolicy -identity Global -BusyOnBusyEnabledType “Unanswered”
}
function Connect-Tdr {
  New-ModVariables
  Test-InitialChecks
  $MSTeamsSettings.azureadsession = Connect-AzureAd
  $MSTeamsSettings.msteamsession = Connect-MicrosoftTeams

  Set-OutputColour "Green" "Validating Azure signed-in User's Role ... "
  $currentUser = (Get-AzureADUser -ObjectId (Get-AzureADCurrentSessionInfo).Account.Id)
  $MyName = $currentUser.DisplayName
  Set-OutputColour "Green" "Welcome: $MyName"
  $MyNameUPN = $currentUser.UserPrincipalName
  $role = Get-AzureADDirectoryRole | Where-Object {$_.displayName -eq 'Global Administrator'}
  $UserRole = Get-AzureADDirectoryRoleMember -ObjectId $role.ObjectId | Where-Object {$_.UserPrincipalName -eq $MyNameUPN}
  $MyNameRoleUPN = $UserRole.UserPrincipalName
  If ($MyNameUPN -eq $MyNameRoleUPN) { 
    Set-OutputColour "Green" "You are a Global Admin, All setup functions are available to you."
    $MSTeamsSettings.role = "Global"
  } Else {
    Set-OutputColour "Red" "You are not a Global Admin. Checking you are a Teams Administrator ..."
    $role = Get-AzureADDirectoryRole | Where-Object {$_.displayName -eq 'Teams Administrator'}
    $UserRole = Get-AzureADDirectoryRoleMember -ObjectId $role.ObjectId | Where-Object {$_.UserPrincipalName -eq $MyNameUPN}
    $MyNameRoleUPN = $UserRole.UserPrincipalName
    if ($MyNameUPN -eq $MyNameRoleUPN) {
      Set-OutputColour "Green" "You are a Teams Admin, Only Teams Setup functions are available to you."
      $MSTeamsSettings.role = "TeamsAdmin"
    } Else {
      Set-OutputColour "Red"  "You are not a Teams Administrator either. You will need to request that either the Global Administrator or Teams Administrator role be assigned to your user account before proceeding"
      Disconnect-Tdr
      break
    }
  }
}
function Disconnect-Tdr {
  Disconnect-AzureAD
  Set-OutputColour "Green" "Successfully Disconnected from AzureAD"
  Disconnect-MicrosoftTeams
  Set-OutputColour "Green" "Successfully Disconnected from MicrosoftTeams"
  $MSTeamsSettings.azureadsession = ""
  $MSTeamsSettings.msteamsession = ""
  New-ModVariables -clear
}
function Disable-TdrUser {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
    [string]$Username
  )
  Test-InitialChecks
  $teamsuser = Get-CsOnlineUser -Identity $Username
  Set-CsUser -Identity $teamsuser.identity -EnterpriseVoiceEnabled $false -HostedVoiceMail $false
  Set-OutputColour "Green" "$username has been disabled"
}
function Enable-TdrUser {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
    [string]$Username,
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=1)]
    [string]$DDI
  )

  Test-DdiFormat $DDI

  $teamsuser = Get-CsOnlineUser -Identity $Username
  $allvoiceroutingpolicies = Get-CsOnlineVoiceRoutingPolicy
  if ($allvoiceroutingpolicies.count -gt 2){
    $count = 0
    foreach($i in $allvoiceroutingpolicies){
      $name = $i.identity -replace 'Tag:(\w+)', '$1'
      Write-Output $count": Press $count for $name"
      $count ++
    }
    $selectedpolicy = Read-Host "Select the Voice Routing Policy to assign to $username"
    $onlinevoiceroutingpolicy = $allvoiceroutingpolicies[$selectedpolicy].identity -replace 'Tag:(\w+)', '$1'
  } else {
    $onlinevoiceroutingpolicy = $allvoiceroutingpolicies[0].identity
  }
  $onlinevoiceroutingpolicy = $onlinevoiceroutingpolicy -replace 'Tag:(\w+)', '$1'
  Set-CsUser -Identity $teamsuser.identity -EnterpriseVoiceEnabled $true -HostedVoiceMail $true -OnPremLineURI tel:$DDI
  Grant-CsOnlineVoiceRoutingPolicy -Identity $teamsuser.identity -PolicyName $onlinevoiceroutingpolicy
  Grant-CsTeamsCallingPolicy -Identity $teamsuser.identity -PolicyName AllowCalling
}
function Check-ModVersion {
  $TdrModPsGallery = find-module MSTeamsDirectRouting
  $TdrModInstalled = Get-Module -ListAvailable MSTeamsDirectRouting

  if ($TdrModInstalled.version -lt $TdrModPsGallery.version){
    Set-OutputColour "Yellow" "A newversion of the MSTeamsDirectRouting module is available"
    Set-OutputColour "Yellow" "it is advisable to update by running Update-Module MSTeamsDirectRouting command before procceding"
  }
}
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
function Set-ModVariables {
  do {
    try {
    [ValidatePattern('^[A-Z]{3}$')]$prefix = Read-Host "Enter the 3 letter prifix to use for this customer, A to Z only" 
    } catch {}
  } until ($?)
  $MSTeamsSettings.prefix = $prefix.ToUpper()
  do {
    try {
      $MSTeamsSettings.onlinepstngateway1 = Read-Host "Enter the primary SBC FQDN"
    } catch {}
  } until ($?)
  $MSTeamsSettings.onlinepstngateway2 = Read-Host "Enter the secondary SBC FQDN"
  $MSTeamsSettings.pstnusage = $MSTeamsSettings.prefix + "-PSTNUsage"
  $MSTeamsSettings.onlinevoiceroute = $MSTeamsSettings.prefix + "-Voice-Route"
  $MSTeamsSettings.onlinevoiceroutingpolicy = $MSTeamsSettings.prefix + "-Route-Policy"
}
function Set-OutputColour($colour, $text) {
  $t = $host.ui.RawUI.ForegroundColor
  $host.ui.RawUI.ForegroundColor = $colour
  Write-Output $text
  $host.ui.RawUI.ForegroundColor = $t
}
function Test-ConnectionStatus($modname){
  if(!($MSTeamsSettings.$modname)) {
    Set-OutputColour "Red" "[❌] Connection to $modname is not present. use the Connect-Tdr command before procceding"
    break
  }
}
function Test-DdiFormat($DDI) {
  $DDI = $DDI -replace '(^[1-9]\d{9}$)', '+44$1' -replace '^0([1-9]\d{9}$)', '+44$1' -replace '^\+440([1-9]\d{9}$)', '+44$1'
  $ddicheck = $DDI -match '^\+44[1-9]\d{9}$'
  if (!($ddicheck)){
    Set-OutputColour "Red" "The DDI must be entered with the full std code without the leading zero or in the E.164 format. e.g. 1273615600 or +441273615600"
    break
  }
  return $DDI
}
function Test-InitialChecks {
  Test-PoshVersion
  if(!($MSTeamsSettings.AzureAD)) {Test-ModuleInstalled AzureAD}
  if(!($MSTeamsSettings.MicrosoftTeams)) {Test-ModuleInstalled MicrosoftTeams}
}
function Test-ModuleInstalled ([string]$modname) {
  $moduleinstalled = Get-Module -ListAvailable $modname
  Set-OutputColour "Green" "Checking $modname module is installed..."
  if (!($moduleinstalled)){
    Set-OutputColour "Yellow" "$modname module is not installed. Installing now..."
    Install-Module -Name $modname -Force
    Import-Module $modname -Force
  }
  $MSTeamsSettings.$modname = "Installed"
}
function Test-PoshVersion {
  $posh_major_version = $PSVersionTable.PSVersion.Major
  if ($posh_major_version -ne "5"){
    Set-OutputColour "Red" "It looks like you arent using the correct version of powershell. The AzureAD module requires Windows Powershell (v5.1) to work."
    Set-OutputColour "Red" "Please launch the correct version and try again."
    break
  }
}
