$scriptParam = ($MyInvocation.Line -replace ('^.*' + [regex]::Escape($MyInvocation.InvocationName)) -split '[;|]')[0].Trim()
$currentDirectory=(Get-Item .).FullName
cd base-vm\build\jenkins
Invoke-Expression ".\launchLocalBuildEnvironment.ps1 $scriptParam"
cd $currentDirectory