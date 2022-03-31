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