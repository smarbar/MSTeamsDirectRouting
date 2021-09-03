Get-ChildItem -Filter *.ps1 -Path $PSScriptRoot\Public\Functions, $PSScriptRoot\Private\Functions -Recurse | ForEach-Object {
  . $_.FullName
}