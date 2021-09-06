function Disconnect-Tdr {
  Disconnect-AzureAD
  Set-OutputColour "Green" "Successfully Disconnected from AzureAD"
  Disconnect-MicrosoftTeams
  Set-OutputColour "Green" "Successfully Disconnected from MicrosoftTeams"
  $MSTeamsSettings.azureadsession = ""
  $MSTeamsSettings.msteamsession = ""
  New-ModVariables -clear
}