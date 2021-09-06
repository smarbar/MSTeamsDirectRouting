function Test-PoshVersion {
  $posh_major_version = $PSVersionTable.PSVersion.Major
  if ($posh_major_version -ne "5"){
    Set-OutputColour "Red" "It looks like you arent using the correct version of powershell. The AzureAD module requires Windows Powershell (v5.1) to work."
    Set-OutputColour "Red" "Please launch the correct version and try again."
    break
  }
}