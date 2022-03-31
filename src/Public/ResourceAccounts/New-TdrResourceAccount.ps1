function New-TdrResourceAccount {
  param(
    [CmdletBinding()]
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
    [string]$Username,
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=1)]
    [string]$displayName,
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=2)]
    [ValidateSet("Queue", "AA")]
    [string]$type
  )
  switch ( $type ) {
      "Queue" { $appType = $MSTeamsSettings.CqGuid    }
      "AA" { $appType = $MSTeamsSettings.AaGuid    }
  }
  New-CsOnlineApplicationInstance -UserPrincipalName $Username -ApplicationId $appType -DisplayName "$displayName"
  if($MSTeamsSettings.role -eq "Gloabl"){
    #assign a virtual user license
  }
}