function Connect-MSTeamsDR {
  Test-InitialChecks
  New-ModVaribles
  $MSTeamsSettings.azureadsession = Connect-AzureAd
  $MSTeamsSettings.msteamsession = Connect-MicrosoftTeams

  Set-OutputColour "Green" "[🔓] Validating Azure signed-in User's Role ... "
  $currentUser = (Get-AzureADUser -ObjectId (Get-AzureADCurrentSessionInfo).Account.Id)
  $MyName = $currentUser.DisplayName
  Set-OutputColour "Green" "[✔] Welcome: $MyName"
  $MyNameUPN = $currentUser.UserPrincipalName
  $role = Get-AzureADDirectoryRole | Where-Object {$_.displayName -eq 'Global Administrator'}
  $UserRole = Get-AzureADDirectoryRoleMember -ObjectId $role.ObjectId | Where-Object {$_.UserPrincipalName -eq $MyNameUPN}
  $MyNameRoleUPN = $UserRole.UserPrincipalName
  If ($MyNameUPN -eq $MyNameRoleUPN) { 
    Set-OutputColour "Green" "[✔] You are a Global Admin, All setup functions are available to you."
    $MSTeamsSettings.role = "Global"
  } Else {
    Set-OutputColour "Red" "[❌] You are not a Global Admin. Checking you are a Teams Administrator ..."
    $role = Get-AzureADDirectoryRole | Where-Object {$_.displayName -eq 'Teams Administrator'}
    $UserRole = Get-AzureADDirectoryRoleMember -ObjectId $role.ObjectId | Where-Object {$_.UserPrincipalName -eq $MyNameUPN}
    $MyNameRoleUPN = $UserRole.UserPrincipalName
    If ($MyNameUPN -eq $MyNameRoleUPN) {
      Set-OutputColour "Green" "[✔] You are a Teams Admin, Only Teams Setup functions are available to you."
      $MSTeamsSettings.role = "TeamsAdmin"
    } Else {
      Set-OutputColour "Red"  "[❌] You are not a Teams Administrator either. You will need to request that either the Global Administrator or Teams Administrator role be assigned to your user account before proceeding"

      break
    }
  }
}

function Disconnect-MSTeamsDR {
  Disconnect-AzureAD
  Disconnect-MicrosoftTeams
  $MSTeamsSettings.azureadsession = ""
  $MSTeamsSettings.msteamsession = ""
}

function Set-OutputColour($colour, $text) {
  $t = $host.ui.RawUI.ForegroundColor
  $host.ui.RawUI.ForegroundColor = $colour
  Write-Output $text
  $host.ui.RawUI.ForegroundColor = $t
}

function Test-InitialChecks {
  Test-PoshVersion
  if(!($MSTeamsSettings.AzureAD)) {Test-ModuleInstalled AzureAD}
  if(!($MSTeamsSettings.MicrosoftTeams)) {Test-ModuleInstalled MicrosoftTeams}
}

function Test-ModuleInstalled ([string]$modname) {
  $moduleinstalled = Get-Module -ListAvailable $modname
  Set-OutputColour "Green" "[❔] Checking $modname module is installed..."
  if (!($moduleinstalled)){
    Set-OutputColour "Yellow" "[🛠] $modname module is not installed. Installing now..."
    Install-Module -Name $modname -Force
    Import-Module $modname -Force
  }
  $MSTeamsSettings.$modname = "Installed"
}

function Test-PoshVersion {
  $posh_major_version = $PSVersionTable.PSVersion.Major
  if ($posh_major_version -ne "5"){
    Set-OutputColour "Red" "[❌] It looks like you arent using the correct version of powershell. The AzureAD module requires Windows Powershell (v5.1) to work."
    Set-OutputColour "Red" "[❌] Please launch the correct version and try again."
    break
  }
}

function Set-ModVariables {
  do {
    try {
    [ValidatePattern('^[A-Z]{3}$')]$prefix = Read-Host "Enter the 3 letter prifix to use for this customer, A to Z only" 
    } catch {}
  } until ($?)
  $MSTeamsSettings.prefix = $prefix.ToUpper()
  $MSTeamsSettings.onlinepstngateway1 = Read-Host "Enter the primary SBC FQDN"
  $MSTeamsSettings.onlinepstngateway2 = Read-Host "Enter the secondary SBC FQDN"
  $MSTeamsSettings.pstnusage = $MSTeamsSettings.prefix + "-PSTNUsage"
  $MSTeamsSettings.onlinevoiceroute = $MSTeamsSettings.prefix + "-Voice-Route"
  $MSTeamsSettings.onlinevoiceroutingpolicy = $MSTeamsSettings.prefix + "-Route-Policy"
  $MSTeamsSettings.numpatt = ".*"
}

function New-ModVaribles {
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
    numpatt = ""
  }
  New-Variable -Name MSTeamsSettings -Value $MSTeamsSettings -Scope Script -Force
}

function New-TeamsRoutingSetup {
  if(!($MSTeamsSettings.msteamsession)) {
    Set-OutputColour "Red" "[❌] Connection to teams is not present. use the Connect-MSTeamsDR command before procceding"
    break
  }
  
  Set-CsOnlinePstnUsage -identity Global -Usage @{Add=$pstnusage}
  New-CsOnlineVoiceRoute -identity $MSTeamsSettings.onlinevoiceroute -NumberPattern $MSTeamsSettings.numpatt -OnlinePstnGatewayList $MSTeamsSettings.onlinepstngateway1, $MSTeamsSettings.onlinepstngateway2 -priority 1 -OnlinePstnUsages $MSTeamsSettings.pstnusage
  New-CsOnlineVoiceRoutingPolicy $MSTeamsSettings.onlinevoiceroutingpolicy -OnlinePstnUsages $MSTeamsSettings.pstnusage
}

function Enable-TeamsUser {
  param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
    [string]$Username,
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=1)]
    [string]$DDI
  )

  # Check user has license assigned

  $DDI = $DDI -replace '(^[1-9]\d{9}$)', '+44$1' -replace '^0([1-9]\d{9}$)', '+44$1' -replace '^\+440([1-9]\d{9}$)', '+44$1'
  $ddicheck = $DDI -match '^\+44[1-9]\d{9}$'
  if (!($ddicheck)){
    Write-host "The DDI must be entered entered with the full std code without the leading zero or in the E.164 format. e.g. 1273615600 or +441273615600"
    return
  }

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

function Disable-TeamsUser {
  param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
    [string]$Username
  )
  Test-InitialChecks
  $teamsuser = Get-CsOnlineUser -Identity $Username
  Set-CsUser -Identity $teamsuser.identity -EnterpriseVoiceEnabled $false -HostedVoiceMail $false
}

















<#
####################################################################################################################################################################

### Create a Tenant Dial Plan, Normalization Rules, Voice Policy, PSTN Usage and Route

# $localdialstring = '+44' + $localstd + '$1'
# $local = New-CsVoiceNormalizationRule -Name 'Local' -Parent Global -Pattern '^([1-9]\d{6})$' -Translation $localdialstring -InMemory
# $national = New-CsVoiceNormalizationRule -Name 'National' -Parent Global -Pattern '^0([1-8]\d{9})$' -Translation '+44$1' -InMemory
# $international = New-CsVoiceNormalizationRule -Name 'International' -Parent Global -Pattern '^00([1-7]\d{*})$' -Translation '+$1' -InMemory
# $premium = New-CsVoiceNormalizationRule -Name 'Premium' -Parent Global -Pattern '^0([9]\d{*})$' -Translation '+44$1' -InMemory
# New-CsTenantDialPlan -Identity $tenantdialplan -NormalizationRules @{Add=$premium,$international,$national,$local}

# bulk enable user voice/voicemail, assign number, assign voice routing policy via CSV import
$FilePath = "C:\Teams"
$csvImport = Import-Csv $FilePath\users.csv

foreach ($item in $csvImport){
  $username = $item.username
  $ddi = "+44" + $item.ddi
  Write-Output "Enabling $username"
  $teamsuser = Get-CsOnlineUser -Identity $username
  Set-CsUser -Identity $teamsuser.id -EnterpriseVoiceEnabled $true -HostedVoiceMail $true -OnPremLineURI tel:$ddi
  Grant-CsOnlineVoiceRoutingPolicy -Identity $teamsuser.id -PolicyName $onlinevoiceroutingpolicy
  # Grant-CsTenantDialPlan -Identity $teamsuser.id -PolicyName $tenantdialplan
  Grant-CsTeamsCallingPolicy -Identity $teamsuser.id -PolicyName AllowCalling
  Write-Output "---------------------------------------------------------------------"
}



##############################################################################################################################################################################################################
### Service setup
## create a user and assign Phone system virtual user license
##Auto-Attendant ID - ce933385-9390-45d1-9512-c8d228074e07
##Call Queue ID - 11cd3e2e-fccb-42ad-ad00-878b93575e07

$aauid = "ce933385-9390-45d1-9512-c8d228074e07"
$cqid = "11cd3e2e-fccb-42ad-ad00-878b93575e07"
$resourceupn = "dukkaboardqueue@trimlinegroup.com"

New-CsOnlineApplicationInstance -UserPrincipalName "bea-reception-queue@e-act.org.uk" -ApplicationId $cqid -DisplayName "BEA Reception Queue"

New-CsOnlineApplicationInstance -UserPrincipalName "bea-main-aa@e-act.org.uk" -ApplicationId $aauid -DisplayName "BEA Main Auto Attendant"

## Set the account location
Set-MsolUser -UserPrincipalName $resourceupn -UsageLocation UK

## Assign a license
## Use this to get your licence type/s
Get-MsolAccountSku

## EXAMPLE
Set-MsolUserLicense -UserPrincipalName $ -AddLicenses "reseller-account:ENTERPRISEPREMIUM"

Set-CsOnlineApplicationInstance -Identity $resourceupn -OnpremPhoneNumber +442087687139



# #Dial Plan
# New-CsTenantDialPlan
# Grant-CsTenantDialPlan
# Set-CsTenantDialPlan -Identity Global
# Get-CsEffectiveTenantDialPlan
# (Get-CsDialPlan Tag:{tag}).NormalizationRules


##############################################################################################################################################################################################################
### Troubleshooting and verification

$teamsuser = Get-CsOnlineUser -Identity "charlotte.stevenson@trimlinegroup.com"
$teamsuser.Id

#check user is homed online
Get-CsOnlineUser -Identity $teamsuser.id | fl RegistrarPool, OnPremLineURI

$teamsuser.OnPremLineURI
$teamsuser.EnterpriseVoiceEnabled
$teamsuser.HostedVoiceMail
$teamsuser.HostedVoicemailPolicy
$teamsuser.VoicePolicy
$teamsuser.HostingProvider
$teamsuser.HostedVoicemailPolicy
$teamsuser.RegistrarPool
$teamsuser.VoiceRoutingPolicy

#>