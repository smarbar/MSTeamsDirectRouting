function Disable-TdrUser {
  [CmdletBinding()]
  param(
      [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
      [string]$Username
  )
  $teamsuser = Get-CsOnlineUser -Identity $Username
  Remove-CsPhoneNumberAssignment -Identity $teamsuser.id -RemoveAll
}