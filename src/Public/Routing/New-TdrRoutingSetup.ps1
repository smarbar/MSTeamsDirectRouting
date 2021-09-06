function New-TdrRoutingSetup {
  Test-ConnectionStatus MicrosoftTeams
  Set-ModVariables
  $OnlinePstnGateway = if($MSTeamsSettings.onlinepstngateway2){$MSTeamsSettings.onlinepstngateway1 + ", " + $MSTeamsSettings.onlinepstngateway2} else {$MSTeamsSettings.onlinepstngateway1}
  Set-CsOnlinePstnUsage -identity Global -Usage @{Add=$pstnusage}
  New-CsOnlineVoiceRoute -identity $MSTeamsSettings.onlinevoiceroute -NumberPattern $MSTeamsSettings.numpatt -OnlinePstnGatewayList = $OnlinePstnGateway -priority 1 -OnlinePstnUsages $MSTeamsSettings.pstnusage
  New-CsOnlineVoiceRoutingPolicy $MSTeamsSettings.onlinevoiceroutingpolicy -OnlinePstnUsages $MSTeamsSettings.pstnusage
  Set-CsTeamsCallingPolicy -identity Global -BusyOnBusyEnabledType “Unanswered”
}