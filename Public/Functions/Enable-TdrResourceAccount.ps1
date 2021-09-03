function Enable-TdrResourceAccount {
  param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
    [string]$Username,
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=1)]
    [string]$DDI
  )
  $resourceAccount = Get-CsOnlineApplicationInstance -Identity $username
  if($resourceAccount) {
    Test-DdiFormat $DDI
    Set-CsOnlineApplicationInstance -Identity $Username -OnpremPhoneNumber $DDI
  } else {
    Set-OutputColour "Red" "$username does not exist yet, please create it and assign the appropriate license first"
  }  
}