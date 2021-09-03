function Test-DdiFormat($DDI) {
  $DDI = $DDI -replace '(^[1-9]\d{9}$)', '+44$1' -replace '^0([1-9]\d{9}$)', '+44$1' -replace '^\+440([1-9]\d{9}$)', '+44$1'
  $ddicheck = $DDI -match '^\+44[1-9]\d{9}$'
  if (!($ddicheck)){
    Set-OutputColour "Red" "The DDI must be entered with the full std code without the leading zero or in the E.164 format. e.g. 1273615600 or +441273615600"
    break
  }
  return $DDI
}