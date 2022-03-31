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