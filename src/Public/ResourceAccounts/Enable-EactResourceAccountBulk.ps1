function Enable-TdrResourceAccountBulk {
  $FilePath = "C:\Teams"
  $csvImport = Import-Csv $FilePath\resource.csv

  $errors = @()

  foreach ($item in $csvImport){ 
    try {
      $username = $item.username
      $ddi = "+44" + $item.ddi
      Write-Output "Enabling $username"
      Enable-TdrResourceAccount -Username $Username -DDI $ddi
    } catch {
      Write-Output "Error enabling $username"
      $errors += $_
    }
    Write-Output "---------------------------------------------------------------------"
  }
  if ($errors) {
    Write-Output "The following errors were encountered"
    $errors
  }
}