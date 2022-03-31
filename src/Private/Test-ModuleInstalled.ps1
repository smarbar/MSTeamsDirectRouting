function Test-ModuleInstalled {
  param(
    [string[]] $modname=@()
  )
  $installed = $false
  foreach ($mod in $modname) {
    if (!($installed)) {
      Set-OutputColour "Green" "Checking $mod module is installed..."
      $moduleinstalled = Get-Module -ListAvailable $mod
      if($moduleinstalled) {
        $installed = $true
        Set-OutputColour "Green" "$mod is installed"
      }
    }
  }
  $newmod = $modname[0]
  if (!($installed)){
    Set-OutputColour "Yellow" "$newmod module is not installed. Installing now..."
    Install-Module -Name $newmod -Force
    Import-Module $newmod -Force
  }
  $MSTeamsSettings.$newmod = "Installed"
}