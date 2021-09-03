function Set-ModVariables {
  do {
    try {
    [ValidatePattern('^[A-Z]{3}$')]$prefix = Read-Host "Enter the 3 letter prifix to use for this customer, A to Z only" 
    } catch {}
  } until ($?)
  $MSTeamsSettings.prefix = $prefix.ToUpper()
  $MSTeamsSettings.onlinepstngateway1 = Read-Host "Enter the primary SBC FQDN"
  $MSTeamsSettings.onlinepstngateway2 = Read-Host "Enter the secondary SBC FQDN"
  $MSTeamsSettings.pstnusage = $MSTeamsSettings.prefix + "-PSTNUsage"
  $MSTeamsSettings.onlinevoiceroute = $MSTeamsSettings.prefix + "-Voice-Route"
  $MSTeamsSettings.onlinevoiceroutingpolicy = $MSTeamsSettings.prefix + "-Route-Policy"
  $MSTeamsSettings.numpatt = ".*"
}