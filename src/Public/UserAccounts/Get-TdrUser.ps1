function Get-TdrUser {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
    [string]$Username
  )

  $teamsuser = Get-CsOnlineUser -Identity $Username
  $teamsuser | select 'UserPrincipalName',
    'identity','OnPremLineURI','OnPremLineURIManuallySet','LineURI','EnterpriseVoiceEnabled','OnPremEnterpriseVoiceEnabled',
    'HostedVoiceMail','HostedVoicemailPolicy','VoicePolicy','HostingProvider','RegistrarPool','VoiceRoutingPolicy','TeamsCallingPolicy',
    'OnlineVoiceRoutingPolicy','CallerIdPolicy','CallingLineIdentity','TeamsUpgradeEffectiveMode','DialPlan','TenantDialPlan' | fl
}