function Disconnect-Tdr {
  <#
  .SYNOPSIS
    Disconnect both AzureAD and Teams sessions
  .DESCRIPTION
    Disconnects any open AzureAD and Microsoft Teams Sessions
  .EXAMPLE
    Disconnect-Tdr
    Disconnects from AzureAD, MicrosoftTeams
    Errors and Warnings are suppressed as no verification of existing sessions is undertaken
  .INPUTS
    None
  .OUTPUTS
    System.string
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
  Set-OutputColour "Green" "Successfully Disconnected from AzureAD"
  Disconnect-MicrosoftTeams
  Set-OutputColour "Green" "Successfully Disconnected from MicrosoftTeams"
  $MSTeamsSettings.azureadsession = ""
  $MSTeamsSettings.msteamsession = ""
  New-ModVariables -clear
}