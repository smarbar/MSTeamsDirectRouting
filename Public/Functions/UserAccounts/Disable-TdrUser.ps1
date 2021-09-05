function Disable-TdrUser {
  <#
  .SYNOPSIS
    Disbale voice on a user
  .DESCRIPTION
    Disbales EnterpriseVoice and HostedVoicemail on a user
  .EXAMPLE
    Disable-TdrUser -username name@domain.com
    Disables EnterpriseVoice and HostedVoicemail on a user
  .INPUTS
    System.string
  .OUTPUTS
    System.string
  .NOTES
    This command will set the EnterpriseVoice and HostedVoicemail fields to $false
  .COMPONENT
    TeamsSession
  .FUNCTIONALITY
    Disbale voice on a user
  .LINK
    https://github.com/smarbar/MSTeamsDirectRouting/tree/main/docs/Disable-TdrUser.md
  .LINK
    https://github.com/smarbar/MSTeamsDirectRouting/tree/main/docs
  #>
  
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
    [string]$Username
  )
  Test-InitialChecks
  $teamsuser = Get-CsOnlineUser -Identity $Username
  Set-CsUser -Identity $teamsuser.identity -EnterpriseVoiceEnabled $false -HostedVoiceMail $false
  Set-OutputColour "Green" "$username has been disabled"
}