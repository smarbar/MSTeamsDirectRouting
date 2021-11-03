function Enable-TdrUser {
  $FilePath = "C:\Teams"
  $csvImport = Import-Csv $FilePath\users.csv

  # need to test data formating
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
}