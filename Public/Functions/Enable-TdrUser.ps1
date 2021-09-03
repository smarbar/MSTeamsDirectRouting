function Enable-TdrUser {
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