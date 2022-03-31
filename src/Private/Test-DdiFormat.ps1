function Test-DdiFormat($DDI) {
  $replaceString = $MSTeamsSettings.countryCode + '$1'
  $ukFormatWithZero = '\' + $MSTeamsSettings.countryCode + '0([1-9]\d{9}$)'
  $DDI = $DDI -replace '(^[1-9]\d{9}$)', $replaceString -replace '^0([1-9]\d{9}$)', $replaceString -replace $ukFormatWithZero, $replaceString
  $ddicheck = $DDI -match '^\+44[1-9]\d{9}$'
  if (!($ddicheck)){
    throw "Incorrect number format"
    # Set-OutputColour "Red" "The DDI must be entered with the full std code without the leading zero or in the E.164 format. e.g. 1273615600 or +441273615600"
    # break
  }
  return $DDI
}