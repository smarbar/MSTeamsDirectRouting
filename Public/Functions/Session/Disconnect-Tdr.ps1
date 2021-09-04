function Disconnect-Tdr {
  <#
  .SYNOPSIS
    Disconnest both AzureAD and Teams sessions
  .DESCRIPTION
    Disconnects any open AzureAD and Microsoft Teams Sessions
  .EXAMPLE
    Disconnect-Tdr
    Disconnects from AzureAD, MicrosoftTeams
    Errors and Warnings are suppressed as no verification of existing sessions is undertaken
  .INPUTS
    None
  .OUTPUTS
    System.tring
  .NOTES
    Disconnects any open AzureAD and Microsoft Teams Sessions
  .COMPONENT
    TeamsSession
  .FUNCTIONALITY
    Disconnects any open AzureAD and Microsoft Teams Sessions
  .LINK
    https://github.com/smarbar/MSTeamsDirectRouting/tree/main/docs/Disconnect-Tdr.md
  .LINK
    https://github.com/smarbar/MSTeamsDirectRouting/tree/main/docs
  #>
  Disconnect-AzureAD
  Disconnect-MicrosoftTeams
  $MSTeamsSettings.azureadsession = ""
  $MSTeamsSettings.msteamsession = ""
  Set-OutputColour "Green" "Disconnected"
  New-ModVariables -clear
}