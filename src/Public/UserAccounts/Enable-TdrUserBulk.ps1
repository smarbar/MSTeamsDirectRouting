function Enable-TdrUserBulk {
  $FilePath = "C:\Teams"
  $csvImport = Import-Csv $FilePath\users.csv

  $allclipolicies = Get-CsCallingLineIdentity

  $errors = @()

  foreach ($item in $csvImport){ 
    try {
      $username = $item.username
      $ddi = $MSTeamsSettings.countryCode + $item.ddi
      $CLIPolicy = $item.clipolicy

      if (!($CLIPolicy)){
        if ($allclipolicies.count -gt 1){
          $count = 0
          foreach($i in $allclipolicies){
            $name = $i.identity -replace 'Tag:(\w+)', '$1'
            Write-Output $count": Press $count for $name"
            $count ++
          }
          $selectedpolicy = Read-Host "Select the CLI Policy to assign to $username"
          $CLIPolicy = $allclipolicies[$selectedpolicy].identity -replace 'Tag:(\w+)', '$1'
        } else {
          $CLIPolicy = $allclipolicies[0].identity
        }
      }
          
      Write-Output "Enabling $username"
      Enable-TdrUser -Username $username -DDI $ddi -CLIPolicy $CLIPolicy
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