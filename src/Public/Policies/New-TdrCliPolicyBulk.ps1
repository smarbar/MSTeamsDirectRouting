function New-TdrCliPolicyBulk {
  $FilePath = "C:\Teams"
  $csvImport = Import-Csv $FilePath\clipolicy.csv

  $errors = @()

  foreach ($item in $csvImport){ 
    try {
      $ResourceUpn = $item.ResourceUpn
      $PolicyName = $item.PolicyName
      $displayName = "$item.displayName"
      Write-Output "Creating $ResourceUpn"
      New-TdrCliPolicy -ResourceUpn $ResourceUpn -PolicyName $PolicyName -DisplayName $DisplayName 
    } catch {
      Write-Output "Error enabling $ResourceUpn"
      $errors += $_
    }
    Write-Output "---------------------------------------------------------------------"
  }
  if ($errors) {
    Write-Output "The following errors were encountered"
    $errors
  }
}