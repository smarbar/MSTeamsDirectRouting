function Check-ModVersion {
  $TdrModPsGallery = find-module MSTeamsDirectRouting
  $TdrModInstalled = Get-Module -ListAvailable MSTeamsDirectRouting

  if ($TdrModInstalled.version -lt $TdrModPsGallery.version){
    Set-OutputColour "Yellow" "A newversion of the MSTeamsDirectRouting module is available"
    Set-OutputColour "Yellow" "it is advisable to update by running Update-Module MSTeamsDirectRouting command before procceding"
  }
}