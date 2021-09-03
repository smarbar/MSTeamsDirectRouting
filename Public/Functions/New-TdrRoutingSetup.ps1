function New-TdrRoutingSetup {
  Test-ConnectionStatus MicrosoftTeams
  Set-ModVariables
  Set-CsOnlinePstnUsage -identity Global -Usage @{Add=$pstnusage}
  New-CsOnlineVoiceRoute -identity $MSTeamsSettings.onlinevoiceroute -NumberPattern $MSTeamsSettings.numpatt -OnlinePstnGatewayList $MSTeamsSettings.onlinepstngateway1, $MSTeamsSettings.onlinepstngateway2 -priority 1 -OnlinePstnUsages $MSTeamsSettings.pstnusage
  New-CsOnlineVoiceRoutingPolicy $MSTeamsSettings.onlinevoiceroutingpolicy -OnlinePstnUsages $MSTeamsSettings.pstnusage
}