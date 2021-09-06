function Set-OutputColour($colour, $text) {
  $t = $host.ui.RawUI.ForegroundColor
  $host.ui.RawUI.ForegroundColor = $colour
  Write-Output $text
  $host.ui.RawUI.ForegroundColor = $t
}