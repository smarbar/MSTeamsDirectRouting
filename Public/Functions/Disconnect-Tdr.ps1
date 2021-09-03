function Disconnect-Tdr {
  Disconnect-AzureAD
  Disconnect-MicrosoftTeams
  $MSTeamsSettings.azureadsession = ""
  $MSTeamsSettings.msteamsession = ""
}