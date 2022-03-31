function Enable-TdrResourceAccount {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
    [string]$Username,
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=1)]
    [string]$DDI
  )
  $licensePlanList = Get-AzureADSubscribedSku
  $userList = Get-AzureADUser -ObjectID $username | Select -ExpandProperty AssignedLicenses | Select SkuID 
  $licenseList = $userList | ForEach { $sku=$_.SkuId ; $licensePlanList | ForEach { If ( $sku -eq $_.ObjectId.substring($_.ObjectId.length - 36, 36) ) { $_.SkuPartNumber } } }
  $virtualUserLicense = $licenselist.contains("PHONESYSTEM_VIRTUALUSER")

  if($virtualUserLicense){
    $resourceAccount = Get-CsOnlineApplicationInstance -Identity $username
    if($resourceAccount) {
      $NEWDDI = Test-DdiFormat $DDI
      Set-CsPhoneNumberAssignment -Identity $resourceAccount.UserPrincipalName -PhoneNumber $newddi -PhoneNumberType DirectRouting
    } else {
      Set-OutputColour "Red" "$Username does not exist yet, please create it and if needed assign the appropriate license first"
    }  
  }
  Else {
    Set-OutputColour "Red" "$Username does not have a Virtual User license assigned, please assign a license and rerun command"
  }  
}