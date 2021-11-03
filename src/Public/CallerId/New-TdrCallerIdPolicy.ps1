function New-TdrCallerIdPolicy {
    [CmdletBinding()]
    param(
      [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
      [string]$PolicyName,
      [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=1)]
      [string]$ResourceAccount,
      [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=2)]
      [string]$NamePresentation,
      [Parameter(Mandatory=$false)]
      [switch]$AllowUserOverride
    )
    
    $ObjId = (Get-CsOnlineApplicationInstance -Identity $ResourceAccount).ObjectId
    switch ($AllowUserOverride) {
        $true { New-CsCallingLineIdentity  -Identity $PolicyName -CallingIDSubstitute Resource -EnableUserOverride $true -ResourceAccount $ObjId -CompanyName NamePresentation}
        $false { New-CsCallingLineIdentity  -Identity $PolicyName -CallingIDSubstitute Resource -EnableUserOverride $false -ResourceAccount $ObjId -CompanyName NamePresentation }
    }
  }