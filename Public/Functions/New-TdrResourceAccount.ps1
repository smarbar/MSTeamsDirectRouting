function New-TdrResourceAccount {
  [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
  [string]$Username,
  [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=1)]
  [string]$displayName,
  [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=2)]
  [ValidateSet("Queue", "AA")]
  [string]$type
  switch ( $type ) {
      "Queue" { $type = $MSTeamsSettings.CqGuid    }
      "AA" { $type = $MSTeamsSettings.AaGuid    }
  }
  New-CsOnlineApplicationInstance -UserPrincipalName $Username -ApplicationId $type -DisplayName "$displayName"
}