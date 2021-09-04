function Connect-Tdr {
  <#
  .SYNOPSIS
    Connects to Azure AD and Teams services using the AzureAD and Microsoft Teams Modules
  .DESCRIPTION
    Connects and conducts various tests to make sure the necessary Powershell version and dependant modules are installed as well as the correct role is assigned to the logged in user
  .EXAMPLE
    Connect-Tdr
    Creates a session to AzureAD with a seperate pop up window promting for credentials
    Creates a session to MicrosoftTeams prompting for selection of existing loed in sessions
  .INPUTS
    None
  .OUTPUTS
    System.string
  .NOTES
    This CmdLet can be used to establish a session to: AzureAD and MicrosoftTeams
    Each Service has different requirements for connection, query (Get-CmdLets), and action (other CmdLets)
    For AzureAD, no particular role is needed for connection and query. Get-CmdLets are available without an Admin-role.
    For MicrosoftTeams, Teams Administrator Role is required
  .COMPONENT
    TeamsSession
  .FUNCTIONALITY
    Connects to AzureAD to confirm the user is assigned either the Global Administrator or Teams Administrator Role
  .LINK
    https://github.com/smarbar/MSTeamsDirectRouting/tree/main/docs/Connect-Tdr.md
  .LINK
    https://github.com/smarbar/MSTeamsDirectRouting/tree/main/docs
  #>
  
  New-ModVariables
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