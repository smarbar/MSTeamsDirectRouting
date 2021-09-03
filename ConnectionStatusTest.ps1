function Test-ConnectionStatus($modname){
  if(!($MSTeamsSettings.$modname)) {
    Set-OutputColour "Red" "[❌] Connection to $modname is not present. use the Connect-Tdr command before procceding"
    break
  }
}