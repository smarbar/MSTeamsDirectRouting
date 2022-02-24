[cmdletbinding()]
param(
    [string[]]$Task = 'ModuleBuild',
    [version]$Version
)

$DependentModules = @('PSDeploy','InvokeBuild','PlatyPS')
Foreach ($Module in $DependentModules){
    If (-not (Get-Module $module -ListAvailable)){
        Install-Module -name $Module -Scope CurrentUser -Force
    }
    Import-Module $module -ErrorAction Stop
}
# Builds the module by invoking psake on the build.psake.ps1 script.
Invoke-Build "$PSScriptRoot\MSTeamsDirectRouting.build.ps1" -Task $Task -Version $Version