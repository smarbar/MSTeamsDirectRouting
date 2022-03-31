function New-TdrCLIPolicy {
    [CmdletBinding()]
    param(
      [Parameter(Mandatory=$true, HelpMessage='Enter the Policy name', ValueFromPipeline=$true, Position=0)]
      [string]$PolicyName,
      [Parameter(Mandatory=$true, HelpMessage='Enter the Resource Account UPN to be assigned', ValueFromPipeline=$true, Position=1)]
      [string]$ResourceAccount,
      [Parameter(Mandatory=$true, HelpMessage='Enter the Policy display name', ValueFromPipeline=$true, Position=2)]
      [string]$DisplayName,
      [Parameter(Mandatory=$false, HelpMessage='Allow the user to override the CLI Policy')]
      [switch]$AllowUserOverride
    )
    
    $ObjId = (Get-CsOnlineApplicationInstance -Identity $ResourceAccount).ObjectId
    New-CsCallingLineIdentity  -Identity $PolicyName -CallingIDSubstitute Resource -EnableUserOverride $AllowUserOverride -ResourceAccount $ObjId -CompanyName $DisplayName
    # switch ($AllowUserOverride) {
    #     $true { New-CsCallingLineIdentity  -Identity $PolicyName -CallingIDSubstitute Resource -EnableUserOverride $true -ResourceAccount $ObjId -CompanyName $DisplayName}
    #     $false { New-CsCallingLineIdentity  -Identity $PolicyName -CallingIDSubstitute Resource -EnableUserOverride $false -ResourceAccount $ObjId -CompanyName $DisplayName }
    # }
  }