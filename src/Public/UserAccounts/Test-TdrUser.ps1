function Test-TdrUser {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true, HelpMessage='Enter the User Account UPN', ValueFromPipeline=$true, Position=0)]
    [string]$Username,
    [Parameter(Mandatory=$true, HelpMessage='Enter the DDI Number to be assigned without the leading 0 e.g. 1273615600', ValueFromPipeline=$true, Position=1)]
    [string]$DDI,
    [Parameter(Position=2)]
    [string]$CLIPolicy
  )
  try {
    $teamsuser = Get-CsOnlineUser -Identity $Username

    $userLicenses = Get-AzureADUserLicenseDetail -ObjectID $username
    $voiceLicense = $userLicenses | foreach { If (($_.SkuPartNumber -eq "MCOEV") -or ($_.SkuPartNumber -eq "SPE_E5")) { $_.SkuPartNumber } }

    If (!($voiceLicense)){
      Set-OutputColour "Red" "$Username has not been assigned a Phone System license"
    }
    ElseIf ($voiceLicense -eq "SPE_E5"){
      $e5License = $userLicenses | where SkuPartNumber -eq "SPE_E5"
      $t = $e5License.ServicePlans | foreach { if ($_.ServicePlanName -eq "MCOEV") {$true} }
      If (!($t)){
        Set-OutputColour "Red" "$Username is assigned with an E5 license but does not have Phone System enabled"
      }
    }
    Else {
      Set-OutputColour "Green" "$Username is assigned with Phone System License"
    }   
  }
  Catch {
    Set-OutputColour "Red" "$username does not exist"
    Break
  }

  try {
    $newddi = Test-DdiFormat $DDI
    Set-OutputColour "Green" "DDI is in the correct format"
  }
  Catch {
    Set-OutputColour "Red" "DDI is not in the correct format"
  }

  If ($CLIPolicy){
    $searchPolicy = "Tag:" + $CLIPolicy
    try{
      $cliPolicyCheck = Get-CsCallingLineIdentity -Identity $searchPolicy
      If ($cliPolicyCheck){
        Set-OutputColour "Green" "CLI Policy exists"
      }
    }
    Catch {
      Set-OutputColour "Red" "CLI Policy does not exist"
    }
  }
}