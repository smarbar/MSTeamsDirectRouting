function Connect-Tdr {
  New-ModVaribles
  Test-InitialChecks
  $MSTeamsSettings.azureadsession = Connect-AzureAd
  $MSTeamsSettings.msteamsession = Connect-MicrosoftTeams

  Set-OutputColour "Green" "Validating Azure signed-in User's Role ... "
  $currentUser = (Get-AzureADUser -ObjectId (Get-AzureADCurrentSessionInfo).Account.Id)
  $MyName = $currentUser.DisplayName
  Set-OutputColour "Green" "Welcome: $MyName"
  $MyNameUPN = $currentUser.UserPrincipalName
  $role = Get-AzureADDirectoryRole | Where-Object {$_.displayName -eq 'Global Administrator'}
  $UserRole = Get-AzureADDirectoryRoleMember -ObjectId $role.ObjectId | Where-Object {$_.UserPrincipalName -eq $MyNameUPN}
  $MyNameRoleUPN = $UserRole.UserPrincipalName
  If ($MyNameUPN -eq $MyNameRoleUPN) { 
    Set-OutputColour "Green" "You are a Global Admin, All setup functions are available to you."
    $MSTeamsSettings.role = "Global"
  } Else {
    Set-OutputColour "Red" "You are not a Global Admin. Checking you are a Teams Administrator ..."
    $role = Get-AzureADDirectoryRole | Where-Object {$_.displayName -eq 'Teams Administrator'}
    $UserRole = Get-AzureADDirectoryRoleMember -ObjectId $role.ObjectId | Where-Object {$_.UserPrincipalName -eq $MyNameUPN}
    $MyNameRoleUPN = $UserRole.UserPrincipalName
    if ($MyNameUPN -eq $MyNameRoleUPN) {
      Set-OutputColour "Green" "You are a Teams Admin, Only Teams Setup functions are available to you."
      $MSTeamsSettings.role = "TeamsAdmin"
    } Else {
      Set-OutputColour "Red"  "You are not a Teams Administrator either. You will need to request that either the Global Administrator or Teams Administrator role be assigned to your user account before proceeding"
      Disconnect-Tdr
      break
    }
  }
}