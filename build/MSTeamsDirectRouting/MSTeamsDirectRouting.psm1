function New-TdrCLIPolicy {
    [CmdletBinding()]
    param(
      [Parameter(Mandatory=$true, HelpMessage='Enter the Policy name', ValueFromPipeline=$true, Position=0)]
      [string]$PolicyName,
      [Parameter(Mandatory=$true, HelpMessage='Enter the Resource Account UPN to be assigned', ValueFromPipeline=$true, Position=1)]
      [string]$ResourceAccount,
      [Parameter(Mandatory=$true, HelpMessage='Enter the Policy display name', ValueFromPipeline=$true, Position=2)]
      [string]$DisplayName,
      [Parameter(Mandatory=$false, HelpMessage='Allow the user to override the CLI Policy')]
      [switch]$AllowUserOverride
    )
    
    $ObjId = (Get-CsOnlineApplicationInstance -Identity $ResourceAccount).ObjectId
    New-CsCallingLineIdentity  -Identity $PolicyName -CallingIDSubstitute Resource -EnableUserOverride $AllowUserOverride -ResourceAccount $ObjId -CompanyName $DisplayName
    # switch ($AllowUserOverride) {
    #     $true { New-CsCallingLineIdentity  -Identity $PolicyName -CallingIDSubstitute Resource -EnableUserOverride $true -ResourceAccount $ObjId -CompanyName $DisplayName}
    #     $false { New-CsCallingLineIdentity  -Identity $PolicyName -CallingIDSubstitute Resource -EnableUserOverride $false -ResourceAccount $ObjId -CompanyName $DisplayName }
    # }
  }
function New-TdrCliPolicyBulk {
  $FilePath = "C:\Teams"
  $csvImport = Import-Csv $FilePath\clipolicy.csv

  $errors = @()

  foreach ($item in $csvImport){ 
    try {
      $ResourceUpn = $item.ResourceUpn
      $PolicyName = $item.PolicyName
      $displayName = "$item.displayName"
      Write-Output "Creating $ResourceUpn"
      New-TdrCliPolicy -ResourceUpn $ResourceUpn -PolicyName $PolicyName -DisplayName $DisplayName 
    } catch {
      Write-Output "Error enabling $ResourceUpn"
      $errors += $_
    }
    Write-Output "---------------------------------------------------------------------"
  }
  if ($errors) {
    Write-Output "The following errors were encountered"
    $errors
  }
}
function Enable-TdrResourceAccountBulk {
  $FilePath = "C:\Teams"
  $csvImport = Import-Csv $FilePath\resource.csv

  $errors = @()

  foreach ($item in $csvImport){ 
    try {
      $username = $item.username
      $ddi = "+44" + $item.ddi
      Write-Output "Enabling $username"
      Enable-TdrResourceAccount -Username $Username -DDI $ddi
    } catch {
      Write-Output "Error enabling $username"
      $errors += $_
    }
    Write-Output "---------------------------------------------------------------------"
  }
  if ($errors) {
    Write-Output "The following errors were encountered"
    $errors
  }
}
function Enable-TdrResourceAccount {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
    [string]$Username,
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=1)]
    [string]$DDI
  )
  $licensePlanList = Get-AzureADSubscribedSku
  $userList = Get-AzureADUser -ObjectID $username | Select -ExpandProperty AssignedLicenses | Select SkuID 
  $licenseList = $userList | ForEach { $sku=$_.SkuId ; $licensePlanList | ForEach { If ( $sku -eq $_.ObjectId.substring($_.ObjectId.length - 36, 36) ) { $_.SkuPartNumber } } }
  $virtualUserLicense = $licenselist.contains("PHONESYSTEM_VIRTUALUSER")

  if($virtualUserLicense){
    $resourceAccount = Get-CsOnlineApplicationInstance -Identity $username
    if($resourceAccount) {
      $NEWDDI = Test-DdiFormat $DDI
      Set-CsPhoneNumberAssignment -Identity $resourceAccount.UserPrincipalName -PhoneNumber $newddi -PhoneNumberType DirectRouting
    } else {
      Set-OutputColour "Red" "$Username does not exist yet, please create it and if needed assign the appropriate license first"
    }  
  }
  Else {
    Set-OutputColour "Red" "$Username does not have a Virtual User license assigned, please assign a license and rerun command"
  }  
}
function New-TdrResourceAccountBulk {
  $FilePath = "C:\Teams"
  $csvImport = Import-Csv $FilePath\resource.csv

  $errors = @()

  foreach ($item in $csvImport){ 
    try {
      $username = $item.username
      $type = $item.type
      $displayName = "$item.displayName"
      Write-Output "Creating $username"
      New-TdrResourceAccount -Username $Username -DisplayName $displayName -Type $type
    } catch {
      Write-Output "Error enabling $username"
      $errors += $_
    }
    Write-Output "---------------------------------------------------------------------"
  }
  if ($errors) {
    Write-Output "The following errors were encountered"
    $errors
  }
}
function New-TdrResourceAccount {
  param(
    [CmdletBinding()]
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
    [string]$Username,
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=1)]
    [string]$displayName,
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=2)]
    [ValidateSet("Queue", "AA")]
    [string]$type
  )
  switch ( $type ) {
      "Queue" { $appType = $MSTeamsSettings.CqGuid    }
      "AA" { $appType = $MSTeamsSettings.AaGuid    }
  }
  New-CsOnlineApplicationInstance -UserPrincipalName $Username -ApplicationId $appType -DisplayName "$displayName"
  if($MSTeamsSettings.role -eq "Gloabl"){
    #assign a virtual user license
  }
}
function New-TdrRoutingSetup {
  Test-ConnectionStatus MicrosoftTeams
  Set-ModVariables
  Set-CsOnlinePstnUsage -identity Global -Usage @{Add=$MSTeamsSettings.pstnusage}
  New-CsOnlineVoiceRoute -identity $MSTeamsSettings.onlinevoiceroute -NumberPattern $MSTeamsSettings.numpatt -OnlinePstnGatewayList $MSTeamsSettings.onlinepstngateway1 -priority 1 -OnlinePstnUsages $MSTeamsSettings.pstnusage
  If($MSTeamsSettings.onlinepstngateway2){
    Set-CsOnlineVoiceRoute -Identity $MSTeamsSettings.onlinevoiceroute -OnlinePstnGatewayList @{add=$MSTeamsSettings.onlinepstngateway2}
  }
  New-CsOnlineVoiceRoutingPolicy $MSTeamsSettings.onlinevoiceroutingpolicy -OnlinePstnUsages $MSTeamsSettings.pstnusage
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
  New-ModVariables -clear
}
function Get-TdrModVariables{
  $MSTeamsSettings
}
function Set-TdrModVariables{
  New-ModVariables
  Set-ModVariables
}
function Disable-TdrUser {
  [CmdletBinding()]
  param(
      [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
      [string]$Username
  )
  $teamsuser = Get-CsOnlineUser -Identity $Username
  Remove-CsPhoneNumberAssignment -Identity $teamsuser.id -RemoveAll
}
function Enable-TdrUser {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true, HelpMessage='Enter the User Account UPN', ValueFromPipeline=$true, Position=0)]
    [string]$Username,
    [Parameter(Mandatory=$true, HelpMessage='Enter the DDI Number to be assigned without the leading 0 e.g. 1273615600', ValueFromPipeline=$true, Position=1)]
    [string]$DDI,
    [Parameter(Position=2)]
    [string]$CLIPolicy
  )
  $newddi = Test-DdiFormat $DDI
  $teamsuser = Get-CsOnlineUser -Identity $Username
  $allclipolicies = Get-CsCallingLineIdentity

  if (!($CLIPolicy)){
    if ($allclipolicies.count -gt 1){
      $count = 0
      foreach($i in $allclipolicies){
        $name = $i.identity -replace 'Tag:(\w+)', '$1'
        Write-Output $count": Press $count for $name"
        $count ++
      }
      $selectedpolicy = Read-Host "Select the CLI Policy to assign to $username"
      $SelectedCLIPolicy = $allclipolicies[$selectedpolicy].identity -replace 'Tag:(\w+)', '$1'
    } else {
      $CLIPolicy = $allclipolicies[0].identity
    }
  } Else {
    $SelectedCLIPolicy = $CLIPolicy
  }
  Set-CsPhoneNumberAssignment -Identity $teamsuser.identity -PhoneNumber $newddi -PhoneNumberType DirectRouting
  Grant-CsOnlineVoiceRoutingPolicy -Identity $teamsuser.identity -PolicyName $MSTeamsSettings.onlinevoiceroutingpolicy
  Grant-CsCallingLineIdentity -Identity $teamsuser.identity -PolicyName $SelectedCLIPolicy
}
function Enable-TdrUserBulk {
  $FilePath = "C:\Teams"
  $csvImport = Import-Csv $FilePath\users.csv

  $allclipolicies = Get-CsCallingLineIdentity

  $errors = @()

  foreach ($item in $csvImport){ 
    try {
      $username = $item.username
      $ddi = $MSTeamsSettings.countryCode + $item.ddi
      $CLIPolicy = $item.clipolicy

      if (!($CLIPolicy)){
        if ($allclipolicies.count -gt 1){
          $count = 0
          foreach($i in $allclipolicies){
            $name = $i.identity -replace 'Tag:(\w+)', '$1'
            Write-Output $count": Press $count for $name"
            $count ++
          }
          $selectedpolicy = Read-Host "Select the CLI Policy to assign to $username"
          $CLIPolicy = $allclipolicies[$selectedpolicy].identity -replace 'Tag:(\w+)', '$1'
        } else {
          $CLIPolicy = $allclipolicies[0].identity
        }
      }
          
      Write-Output "Enabling $username"
      Enable-TdrUser -Username $username -DDI $ddi -CLIPolicy $CLIPolicy
    } catch {
      Write-Output "Error enabling $username"
      $errors += $_
    }
    Write-Output "---------------------------------------------------------------------"
  }
  if ($errors) {
    Write-Output "The following errors were encountered"
    $errors
  }
}
function Get-TdrUser {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
    [string]$Username
  )

  $teamsuser = Get-CsOnlineUser -Identity $Username
  $teamsuser | select 'UserPrincipalName',
    'identity','OnPremLineURI','OnPremLineURIManuallySet','LineURI','EnterpriseVoiceEnabled','OnPremEnterpriseVoiceEnabled',
    'HostedVoiceMail','HostedVoicemailPolicy','VoicePolicy','HostingProvider','RegistrarPool','VoiceRoutingPolicy','TeamsCallingPolicy',
    'OnlineVoiceRoutingPolicy','CallerIdPolicy','CallingLineIdentity','TeamsUpgradeEffectiveMode','DialPlan','TenantDialPlan' | fl
}
function Test-TdrUser {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true, HelpMessage='Enter the User Account UPN', ValueFromPipeline=$true, Position=0)]
    [string]$Username,
    [Parameter(Mandatory=$true, HelpMessage='Enter the DDI Number to be assigned without the leading 0 e.g. 1273615600', ValueFromPipeline=$true, Position=1)]
    [string]$DDI,
    [Parameter(Position=2)]
    [string]$CLIPolicy
  )
  try {
    $teamsuser = Get-CsOnlineUser -Identity $Username

    $userLicenses = Get-AzureADUserLicenseDetail -ObjectID $username
    $voiceLicense = $userLicenses | foreach { If (($_.SkuPartNumber -eq "MCOEV") -or ($_.SkuPartNumber -eq "SPE_E5")) { $_.SkuPartNumber } }

    If (!($voiceLicense)){
      Set-OutputColour "Red" "$Username has not been assigned a Phone System license"
    }
    ElseIf ($voiceLicense -eq "SPE_E5"){
      $e5License = $userLicenses | where SkuPartNumber -eq "SPE_E5"
      $t = $e5License.ServicePlans | foreach { if ($_.ServicePlanName -eq "MCOEV") {$true} }
      If (!($t)){
        Set-OutputColour "Red" "$Username is assigned with an E5 license but does not have Phone System enabled"
      }
    }
    Else {
      Set-OutputColour "Green" "$Username is assigned with Phone System License"
    }   
  }
  Catch {
    Set-OutputColour "Red" "$username does not exist"
    Break
  }

  try {
    $newddi = Test-DdiFormat $DDI
    Set-OutputColour "Green" "DDI is in the correct format"
  }
  Catch {
    Set-OutputColour "Red" "DDI is not in the correct format"
  }

  If ($CLIPolicy){
    $searchPolicy = "Tag:" + $CLIPolicy
    try{
      $cliPolicyCheck = Get-CsCallingLineIdentity -Identity $searchPolicy
      If ($cliPolicyCheck){
        Set-OutputColour "Green" "CLI Policy exists"
      }
    }
    Catch {
      Set-OutputColour "Red" "CLI Policy does not exist"
    }
  }
}
function Test-TdrUserBulk {
  $FilePath = "C:\Teams"
  $csvImport = Import-Csv $FilePath\users.csv

  $errors = @()

  foreach ($item in $csvImport){ 
    try {
      $username = $item.username
      $ddi = $item.ddi
      $CLIPolicy = $item.clipolicy          
      Write-Output "Testing $username"
      Test-TdrUser -Username $username -DDI $ddi -CLIPolicy $CLIPolicy
    } catch {
      Write-Output "Error testing $username"
      $errors += $_
    }
    Write-Output "---------------------------------------------------------------------"
  }
  if ($errors) {
    Write-Output "The following errors were encountered"
    $errors
  }
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
    countryCode = "+44"
    numpatt = ".*"
    AaGuid = "ce933385-9390-45d1-9512-c8d228074e07"
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
    [ValidatePattern('^[A-Z]{3}$')]$prefix = Read-Host "Enter the 3 letter prifix to use for this Direct Routing connection, A to Z only" 
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
    Set-OutputColour "Red" "Connection to $modname is not present. use the Connect-Tdr command before procceding"
    break
  }
}
function Test-DdiFormat($DDI) {
  $replaceString = $MSTeamsSettings.countryCode + '$1'
  $ukFormatWithZero = '\' + $MSTeamsSettings.countryCode + '0([1-9]\d{9}$)'
  $DDI = $DDI -replace '(^[1-9]\d{9}$)', $replaceString -replace '^0([1-9]\d{9}$)', $replaceString -replace $ukFormatWithZero, $replaceString
  $ddicheck = $DDI -match '^\+44[1-9]\d{9}$'
  if (!($ddicheck)){
    throw "Incorrect number format"
    # Set-OutputColour "Red" "The DDI must be entered with the full std code without the leading zero or in the E.164 format. e.g. 1273615600 or +441273615600"
    # break
  }
  return $DDI
}
function Test-InitialChecks {
  Test-PoshVersion
  if(!($MSTeamsSettings.AzureAD)) {Test-ModuleInstalled "AzureAD","AzureAdPreview"}
  if(!($MSTeamsSettings.MicrosoftTeams)) {Test-ModuleInstalled "MicrosoftTeams"}
}
function Test-ModuleInstalled {
  param(
    [string[]] $modname=@()
  )
  $installed = $false
  foreach ($mod in $modname) {
    if (!($installed)) {
      Set-OutputColour "Green" "Checking $mod module is installed..."
      $moduleinstalled = Get-Module -ListAvailable $mod
      if($moduleinstalled) {
        $installed = $true
        Set-OutputColour "Green" "$mod is installed"
      }
    }
  }
  $newmod = $modname[0]
  if (!($installed)){
    Set-OutputColour "Yellow" "$newmod module is not installed. Installing now..."
    Install-Module -Name $newmod -Force
    Import-Module $newmod -Force
  }
  $MSTeamsSettings.$newmod = "Installed"
}
function Test-PoshVersion {
  $posh_major_version = $PSVersionTable.PSVersion.Major
  if ($posh_major_version -ne "5"){
    Set-OutputColour "Red" "It looks like you arent using the correct version of powershell. The AzureAD module requires Windows Powershell (v5.1) to work."
    Set-OutputColour "Red" "Please launch the correct version and try again."
    break
  }
}
function Test-TdrDomain {
  Get-CsTenant | fl tenantid,domain* 
}
