function New-TdrRoutingSetup {
  <#
  .SYNOPSIS
    Creates the basic routing infrastructure for direct routing
  .DESCRIPTION
    Creates a PSTNUsage, VoiceRoute and VoiceRoutingPolicy and links them together based off of user input 
  .EXAMPLE
    New-TdrRoutingSetup
    Create a PSTNUsage in the format XXX-PSTNUsage based of a 3 digit prefix entered at the command prompt
    Creates a VoiceRoute in the format XXX-Voice-Route and assigns the 2 FQDNs entered at the command prompt it also associates the previously created PSTNUsage
    Creates a VoiceRoutingPolicy in the format XXX-Route-Polcy and associates the previously created PSTNUsage
  .INPUTS
    System.string
  .OUTPUTS
    System.string
  .NOTES
    This command will create the basic routing records needed to use direct routing  
    This CmdLet can be used to establish a session to: AzureAD and MicrosoftTeams
    Each Service has different requirements for connection, query (Get-CmdLets), and action (other CmdLets)
    For AzureAD, no particular role is needed for connection and query. Get-CmdLets are available without an Admin-role.
    For MicrosoftTeams, Teams Administrator Role is required
  .COMPONENT
    TeamsSession
  .FUNCTIONALITY
    Connects to AzureAD to confirm the user is assigned either the Global Administrator or Teams Administrator Role
  .LINK
    https://github.com/smarbar/MSTeamsDirectRouting/tree/main/docs/New-TdrRoutingSetup.md
  .LINK
    https://github.com/smarbar/MSTeamsDirectRouting/tree/main/docs
  #>
  # [CmdletBinding()]
  # param(
  #   [Parameter(Mandatory=$false, ValueFromPipeline=$true, Position=0)]
  #   [ValidatePattern('^[A-Z]{3}$')]
  #   [string]$prefix,
  #   [Parameter(Mandatory=$false, ValueFromPipeline=$true, Position=1)]
  #   [string]$PSTNGateway1,
  #   [Parameter(Mandatory=$false, ValueFromPipeline=$true, Position=2)]
  #   [string]$PSTNGateway2
  # )
  Test-ConnectionStatus MicrosoftTeams
  Set-ModVariables
  $OnlinePstnGateway = if($MSTeamsSettings.onlinepstngateway2){$MSTeamsSettings.onlinepstngateway1 + ", " + $MSTeamsSettings.onlinepstngateway2} else {$MSTeamsSettings.onlinepstngateway1}
  Set-CsOnlinePstnUsage -identity Global -Usage @{Add=$pstnusage}
  New-CsOnlineVoiceRoute -identity $MSTeamsSettings.onlinevoiceroute -NumberPattern $MSTeamsSettings.numpatt -OnlinePstnGatewayList = $OnlinePstnGateway -priority 1 -OnlinePstnUsages $MSTeamsSettings.pstnusage
  New-CsOnlineVoiceRoutingPolicy $MSTeamsSettings.onlinevoiceroutingpolicy -OnlinePstnUsages $MSTeamsSettings.pstnusage
}