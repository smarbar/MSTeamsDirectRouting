function Test-TdrUserBulk {
  $FilePath = "C:\Teams"
  $csvImport = Import-Csv $FilePath\users.csv

  $errors = @()

  foreach ($item in $csvImport){ 
    try {
      $username = $item.username
      $ddi = $item.ddi
      $CLIPolicy = $item.clipolicy          
      Write-Output "Testing $username"
      Test-TdrUser -Username $username -DDI $ddi -CLIPolicy $CLIPolicy
    } catch {
      Write-Output "Error testing $username"
      $errors += $_
    }
    Write-Output "---------------------------------------------------------------------"
  }
  if ($errors) {
    Write-Output "The following errors were encountered"
    $errors
  }
}