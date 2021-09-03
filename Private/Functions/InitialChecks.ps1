function Test-InitialChecks {
  Test-PoshVersion
  if(!($MSTeamsSettings.AzureAD)) {Test-ModuleInstalled AzureAD}
  if(!($MSTeamsSettings.MicrosoftTeams)) {Test-ModuleInstalled MicrosoftTeams}
}