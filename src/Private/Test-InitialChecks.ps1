function Test-InitialChecks {
  Test-PoshVersion
  if(!($MSTeamsSettings.AzureAD)) {Test-ModuleInstalled "AzureAD","AzureAdPreview"}
  if(!($MSTeamsSettings.MicrosoftTeams)) {Test-ModuleInstalled "MicrosoftTeams"}
}