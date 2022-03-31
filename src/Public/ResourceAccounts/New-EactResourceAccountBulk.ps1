function New-TdrResourceAccountBulk {
  $FilePath = "C:\Teams"
  $csvImport = Import-Csv $FilePath\resource.csv

  $errors = @()

  foreach ($item in $csvImport){ 
    try {
      $username = $item.username
      $type = $item.type
      $displayName = "$item.displayName"
      Write-Output "Creating $username"
      New-TdrResourceAccount -Username $Username -DisplayName $displayName -Type $type
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