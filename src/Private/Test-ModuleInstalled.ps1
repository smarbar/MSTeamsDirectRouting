function Test-ModuleInstalled ([string]$modname) {
  $moduleinstalled = Get-Module -ListAvailable $modname
  Set-OutputColour "Green" "Checking $modname module is installed..."
  if (!($moduleinstalled)){
    Set-OutputColour "Yellow" "$modname module is not installed. Installing now..."
    Install-Module -Name $modname -Force
    Import-Module $modname -Force
  }
  $MSTeamsSettings.$modname = "Installed"
}