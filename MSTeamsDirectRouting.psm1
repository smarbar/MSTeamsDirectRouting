<#
  MSTeamsDirectRouting
  Module for Management of Teams Voice Configuration for Tenant and Users
  User Configuration for Voice, Creation and connection of Resource Accounts,
  Creation and Management of Call Queues and Auto Attendants
  by Scott Barrett
  https://github.com/smarbar
.LINK
  https://github.com/smarbar/MSTeamsDirectRouting/tree/main/docs
#>

# Exporting Module Members (Functions)
Export-ModuleMember -Function $(Get-ChildItem -Include *.ps1 -Path $PSScriptRoot\Public\Functions -Recurse).BaseName

Get-ChildItem -Filter *.ps1 -Path $PSScriptRoot\Public\Functions, $PSScriptRoot\Private\Functions -Recurse | ForEach-Object {
  . $_.FullName
}