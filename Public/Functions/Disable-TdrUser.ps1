function Disable-TdrUser {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
    [string]$Username
  )
  Test-InitialChecks
  $teamsuser = Get-CsOnlineUser -Identity $Username
  Set-CsUser -Identity $teamsuser.identity -EnterpriseVoiceEnabled $false -HostedVoiceMail $false
}