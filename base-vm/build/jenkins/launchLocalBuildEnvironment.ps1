$scriptParam = ($MyInvocation.Line -replace ('^.*' + [regex]::Escape($MyInvocation.InvocationName)) -split '[;|]')[0].Trim()

$Log_Level = "info"

# List all required version prerequisites. These are the versions this script has been tested with.
# In particular Mac OpenSSL will cause issues if not the correct version
$vagrantVersionRequired="2.3.4"
$virtualboxVersionRequired="7.0.6"
$vmwareRequiredVersion="1.17.0"
$parallelsVersionRequired="18.2.0"
$packerVersionRequired="1.8.6"

# Executable paths if required
$virtualboxCliPath = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
$vmWareDiskUtilityPath = "C:\Program Files (x86)\VMware\VMware Workstation\vmware-vdiskmanager.exe"
$vmwareCliPath = "C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe"
$opensslVersionRequired = "1.1.1"

# Define ansi colours
function Green
{
    process { Write-Host $_ -ForegroundColor White }
}

function Green
{
    process { Write-Host $_ -ForegroundColor Green }
}

function Red
{
    process { Write-Host $_ -ForegroundColor Red }
}

function Orange
{
    process { Write-Host $_ -ForegroundColor DarkYellow }
}

function Blue
{
    process { Write-Host $_ -ForegroundColor Blue }
}

function Log_Info
{
    param ([string]$Message,[string]$Colour="White")

    if ($Log_Level -eq "info" -Or $Log_Level -eq  "error" -Or $Log_Level -eq "warn" -Or $Log_Level -eq "debug")
    {
        Write-Host "[INFO] $Message" -ForegroundColor ${Colour}
    }
}

function Log_Debug
{
    param ([string]$Message,[string]$Colour="White")

    if ($Log_Level -eq "debug")
    {
        Write-Host "[DEBUG] $Message" -ForegroundColor ${Colour}
    }
}

function Log_Warn
{
    param ([string]$Message,[string]$Colour="DarkYellow")

    if ( $Log_Level -eq  "error" -Or $Log_Level -eq "warn" -Or $Log_Level -eq "debug" -Or $Log_Level -eq "info")
    {
        Write-Host "[WARN] $Message" -ForegroundColor ${Colour}
    }
}

function Log_Error
{
    param ([string]$Message,[string]$Colour="Red")

    if ( $Log_Level -eq  "error" -Or $Log_Level -eq "warn" -Or $Log_Level -eq "debug" -Or $Log_Level -eq "info")
    {
        Write-Host "[ERROR] $Message" -ForegroundColor ${Colour}
    }
}

function checkExecutableExists
{
    param ([string]$executableToCheck, [string]$warnOrErrorIfNotExist)

    Log_Debug([System.IO.Path]::IsPathRooted($executableToCheck))

    # Define path to executable
    if ( [System.IO.Path]::IsPathRooted($executableToCheck))
    {
        $executablePath = $executableToCheck
    }
    else
    {

        if ( (Get-Command $executableToCheck -ea 0) -ne $null ) {
            Log_Debug "Check again: $executableToCheck"
            $executablePath = (Get-Command $executableToCheck -ea 0).path
            Log_Debug "Check again: $executablePath"
        } else {
            $executablePath = $null
        }
    }

    Log_Debug "$executableToCheck"

    # Check if executable exists
    if ( $executablePath -ne $null )
    {
        if (!( Test-Path -Path $executablePath))
        {
            if ($warnOrErrorIfNotExist -eq "warn")
            {
                Log_Warn "Executable $executablePath does not exist at the given path."
                $global:checkWarnings++
            }
            else
            {
                Log_Error "Executable $executablePath does not exist at the given path."
                $global:checkErrors++
            }
            return "1"
        }
        else
        {
            Log_Info "Executable $executablePath exists."
            return "0"
        }
    } else {
        log_debug "$executableToCheck could not be found"
        if ($warnOrErrorIfNotExist -eq "warn")
        {
            Log_Warn "Executable $executableToCheck path not found."
            $global:checkWarnings++
        }
        else
        {
            Log_Error "Executable $executableToCheck path not found."
            $global:checkErrors++
        }
        return "1"
    }

}

function versionCompare {
    param ([string]$currentVersion, [string]$expectedVersion, [string]$executable)
    if ($currentVersion -ge $expectedVersion)
    {
        Log_Info "Installed `"${executable}`" version is `"${currentVersion}`", which is equal to or greater than the expected `"${expectedVersion}`""
    } else {
        Log_Warn "Installed `"${executable}`" version is `"${currentVersion}`", which is less than the expected `"${expectedVersion}`". Whilst this may work, in some cases this may result in compatibility issues!"
        $global:checkWarnings++
    }
}

function checkVMWareVersion
{

    $checkResponse = (checkExecutableExists "$vmWareDiskUtilityPath" "warn")[0]
    $checkResponse = (checkExecutableExists "$vmwareCliPath" "warn")[0]
    Log_Debug "checkResponse: ${checkResponse}"
    if ("${checkResponse}" -eq 0)
    {
        Log_Debug "VMWare installed. Proceeding to check version"

        $installedVmwareVersion = & "$vmwareCliPath" | Select-String '((?:\d{1,3}\.){2}\d{1,3})' | ForEach-Object { $_.Matches[0].Groups[1].Value }
        Log_Debug ($installedVmwareVersion)
        versionCompare "${installedVmwareVersion}" "${vmwareRequiredVersion}" "VMWare"
        $global:availableVirtualizationPlatforms++

    }
}

function checkVirtualBoxVersion
{

    $checkResponse = (checkExecutableExists "$virtualboxCliPath" "warn")[0]
    Log_Debug "checkResponse: ${checkResponse}"
    if ("${checkResponse}" -eq 0)
    {
        Log_Debug "VirtualBox installed. Proceeding to check version"

        $installedVirtualBoxVersion = & "$virtualboxCliPath" --version | Select-String '((?:\d{1,3}\.){2}\d{1,3})' | ForEach-Object { $_.Matches[0].Groups[1].Value }
        Log_Debug ($installedVirtualBoxVersion)
        versionCompare "${installedVirtualBoxVersion}" "${virtualboxVersionRequired}" "VirtualBox"
        $global:availableVirtualizationPlatforms++

    }
}

function checkVagrantVersion
{

    $checkResponse = (checkExecutableExists "vagrant" "error")[0]
    Log_Debug "checkResponse: ${checkResponse}"
    if ("${checkResponse}" -eq 0)
    {
        Log_Debug "Vagrant installed. Proceeding to check version"

        $installedVagrantVersion = & "vagrant" version | Select-String '((?:\d{1,3}\.){2}\d{1,3})' | ForEach-Object { $_.Matches[0].Groups[1].Value } | Select -First 1
        Log_Debug ($installedVagrantVersion)
        versionCompare "${installedVagrantVersion}" "${vagrantVersionRequired}" "Vagrant"
    } else {
        Log_Error "Vagrant not installed. Please install and try again."
        Log_Error "You can download Vagrant from https://www.vagrantup.com/Downloads"
    }
}

function checkOpenSslVersion
{

    $checkResponse = (checkExecutableExists "openssl" "error")[0]
    Log_Debug "checkResponse: ${checkResponse}"
    if ("${checkResponse}" -eq 0)
    {
        Log_Debug "OpenSSL installed. Proceeding to check version"

        $installedOpenSslVersion = & "openssl" version | Select-String '((?:\d{1,3}\.){2}\d{1,3})' | ForEach-Object { $_.Matches[0].Groups[1].Value }
        Log_Debug ($installedOpenSslVersion)
        versionCompare "${installedOpenSslVersion}" "${opensslVersionRequired}" "OpenSSL"
    }
}

# Set warnings and error count
$global:checkWarnings = 0
$global:checkErrors = 0
$global:availableVirtualizationPlatforms = 0

function checkVersions
{

    param ([string]$scriptParam)

    checkVMWareVersion
    checkVirtualBoxVersion
    checkVagrantVersion
    #checkOpenSslVersion

    Log_Debug "Errors: ${checkErrors}"
    Log_Debug "Warnings: ${checkWarnings}"
    Log_Debug "Available Virtualization Platforms: ${availableVirtualizationPlatforms}"

    Log_Debug "Received script argument: $scriptParam"

    if ( $checkErrors -gt 0 )
    {
        Log_Error "There were errors during dependency checks. Please resolve these issues and relaunch the script."
        Exit 1
    } elseif ($checkWarnings -gt 0 -And $scriptParam -ne "-i" )
    {
        Log_Warn "There was/were ${checkWarnings} warning(s) during the dependency version checks. You can choose to ignore these by starting the script with the -i option."
        Log_Warn "Be aware that old versions of dependencies may result in the solution not working correctly."
        Exit 1
    } elseif ( $checkWarnings -gt 0 -And $scriptParam -eq "-i" )
    {
        Log_Warn "There was/were ${checkWarnings} warning(s) during the dependency version checks. Will continue anyway, as you started this script with the -i option."
        Log_Warn "Be aware that old versions of dependencies may result in the solution not working correctly."
    }

}

if ( $scriptParam ) {
    switch ( $scriptParam )
    {
        -i {
            $override_action = "ignore-warnings"
            $areYouSureQuestion="Are you sure you want to ignore the warnings and continue anyway?"
        }
        -r {
            $override_action = "recreate"
            $areYouSureQuestion = "Are you sure you want to recreate the jobs in the jenkins environment?"
        }
        -d {
            $override_action = "destroy"
            $areYouSureQuestion = "Are you sure you want to destroy and rebuild the jenkins environment, losing all history?"
        }
        -f {
            $override_action = "fully-destroy"
            $areYouSureQuestion = "Are you sure you want to fully destroy and rebuild the jenkins environment, losing all history, virtual-machines and built images?"
        }
        -u {
            $override_action = "uninstall"
            $areYouSureQuestion = "Are you sure you want to uninstall the jenkins environment?"
        }
        -s {
            $override_action = "stop"
            $areYouSureQuestion = "Are you sure you want to stop the jenkins environment?"
        }
        -h {
            Write-Output "The .\launchLocalBuildEnvironment.ps1 script has the following options:
              -i  [i]gnore warnings and start the launcher anyway, knowing that this may cause issues
              -d  [d]estroy and rebuild Jenkins environment. All history is also deleted
              -f  [f]ully destroy and rebuild, including ALL built images and ALL KX.AS.CODE virtual machines!
              -h  [h]elp me and show this help text
              -r  [r]ecreate Jenkins jobs with updated parameters. Will keep history
              -s  [s]top the Jenkins build environment
              -u  [u]ninstall and give me back my disk space`n"
            Exit
        }
        default {
            Log_Error "Invalid option: $($scriptParam). Call .\launchLocalBuildEnvironment.ps1 -h to display help text`n"
            .\launchLocalBuildEnvironment.ps1 -h
            Exit
        }
    }
}

$ErrorActionPreference = "SilentlyContinue"

# Settings that will be used for provisioning Jenkins, including credentials etc
if ( ! ( Test-Path -Path ".\jenkins.env" ) )
{
    Log_Error "Please create the jenkins.env file in the base-vm/build/jenkins folder by copying the template (jenkins.env.template --> jenkins.env), and adding/amending the values"
    Exit
}

if ( $args.count -gt 1 ) {
    Log_Error "You must provide one parameter only"
    Exit
}

if ($areYouSureQuestion) {
    Write-Host -ForegroundColor Blue "$areYouSureQuestion"
    $Input = Read-Host -Prompt "[Y/N]"
    Write-Output $Input
}

if ( $override_action -eq "stop" -Or  $override_action -eq "recreate" -Or $override_action -eq "destroy" -Or $override_action -eq "fully-destroy" -Or $override_action -eq "uninstall" )
{
    Write-Output "Stopping Jenkins..."
    $jenkinsPid = Get-Content -Path .\jenkinsPid
    Stop-Process -ID $jenkinsPid -Force
    Remove-Item -Recurse -Force -Path .\jenkinsPid
    if ( $override_action -eq "stop" )
    {
        Exit
    }
}

if ( $override_action -eq "recreate" -Or $override_action -eq "destroy" -Or $override_action -eq "fully-destroy" -Or $override_action -eq "uninstall" ) {

    if (  $Input -eq "Y" ) {
        Log_Info "OK! Proceeding to ${override_action} the KX.AS.CODE Jenkins environment"
        Log_info "Deleting Jenkins jobs..."
        Get-ChildItem "$JENKINS_HOME\jobs" -Recurse -Filter config.xml |
                Foreach-Object {
                    Remove-Item -Force -Path  $_.FullName
                }
        Log_Info "Jenkins jobs deleted"
        if ( $override_action -eq "destroy" -Or $override_action -eq "fully-destroy" -Or $override_action -eq "uninstall" )
        {
            Log_Info "Deleting jenkins_home directory..."
            Remove-Item -Recurse -Force -Path .\jenkins_home
            Remove-Item -Force -Path .\.vmCredentialsFile
            Remove-Item -Force -Path .\.hash
            Remove-Item -Force -Path .\cookies
            Log_Info "jenkins_home deleted"
            if ($override_action -eq "fully-destroy")
            {
                Log_Info "Deleting jenkins_shared_workspace directory..."
                Remove-Item -Recurse -Force -Path .\jenkins_shared_workspace
                Log_Info "jenkins_shared_workspace deleted"
            }
            Log_Info "Deleting downloaded tools..."
            Remove-Item -Force -Path .\jq.exe
            Remove-Item -Force -Recurse -Path .\java
            Remove-Item -Force -Recurse -Path .\git
            Remove-Item -Force -Path .\amazon-corretto-windows-x64.zip
            Remove-Item -Force -Path .\jenkins-cli.jar
            Remove-Item -Force -Path .\jenkins.war
            Remove-Item -Force -Path .\jenkins-plugin-manager.jar
            Remove-Item -Force -Path .\portable-git-archive.exe
            Log_Info "Downloaded tools deleted"
        }
        if ( $override_action -eq "uninstall" )
        {
            Write-Output "Uninstall complete"
            Exit
        }
        Exit
    } else {
        Write-Output "Cancelling request to $override_action as response was $Input"
        Exit
    }
}

Remove-Item -Force -Path 'jenkins.env.ps1'
Foreach ($line in (Get-Content -Path "jenkins.env" | Where-Object {$_ -notmatch '^#.*'} | Where-Object {$_ -notmatch '^$'}))
{
    # Created for sourcing for this script
    $line -replace '^', '$' | Add-Content -Path 'jenkins.env.ps1'
}

. ./jenkins.env.ps1

# Add OpenSSL binary to PATH if provided in jenkins.env
if ( $openssl_path -ne "" ) {
    $env:Path = "$openssl_path;" + $env:Path
}

checkVersions $scriptParam

# Download curl.exe if not installed. Installed as standard on Windows 10 & 11
if ( ! (which curl.exe)) {
    Invoke-WebRequest $curlDownloadUrl -OutFile .\curl.exe
}

$downloadAndInstallPortableGit = $null

if ( ( Test-Path -Path "$PSScriptRoot\git\bin\git.exe" ) -And ( Test-Path -Path "$PSScriptRoot\git\usr\bin\nohup.exe" ) -And ( Test-Path -Path "C:\Program Files\git\usr\bin\msys-2.0.dll" ) )
{
    Log_Info "Git was already downloaded and is available in the KX.AS.CODE directory. Skipping further Git checks"
}
else
{
    # Checking Windows specific pre-requisites
    # Git bash must be installed and available, else "sh" will not work in the Jenkins pipeline
    if ((Get-Command "C:\Program Files\Git\bin\git.exe" -ErrorAction SilentlyContinue) -And (Get-Command "C:\Program Files\Git\bin\sh.exe" -ErrorAction SilentlyContinue))
    {
        $path_to_git_executable = "C:\Program Files\Git\bin\git.exe"
        $path_to_sh_executable = "C:\Program Files\Git\bin\sh.exe"
        $env:Path = "C:\Program Files\Git\bin\;" + $env:Path
    }
    elseif ( (Get-Command "$Env:HOMEDRIVE$Env:HOMEPATH\AppData\Local\Programs\Git\bin\git.exe"  -ErrorAction SilentlyContinue) -And (Get-Command "$Env:HOMEDRIVE$Env:HOMEPATH\AppData\Local\Programs\Git\bin\sh.exe"  -ErrorAction SilentlyContinue) )
    {
        $path_to_git_executable = "$Env:HOMEDRIVE$Env:HOMEPATH\AppData\Local\Programs\Git\bin\git.exe"
        $path_to_sh_executable = "$Env:HOMEDRIVE$Env:HOMEPATH\AppData\Local\Programs\Git\bin\sh.exe"
        $env:Path = "$Env:HOMEDRIVE$Env:HOMEPATH\AppData\Local\Programs\Git\bin;" + $env:Path
    }
    else
    {
        $path_to_git_executable = $null
        Log_Info "Did not find git.exe. Will download and use a portable version"
        $downloadAndInstallPortableGit = "true"
    }

    # Check if nohup.exe and associated DLLs exist
    # Due to a Jenkins issue, nohup.exe and associated DLLs will only be picked up by Jenkins, if they are located in the C:\Program Files\git\usr\bin directory
    # Even if they ae on the path elsewhere, Jenkins Groovy pipeine "sh" calls will fail if not in C:\Program Files\git\usr\bin
    if ((Get-Command "C:\Program Files\Git\usr\bin\nohup.exe" -ErrorAction SilentlyContinue) -And ( Test-Path -Path "C:\Program Files\git\usr\bin\msys-2.0.dll") -And ( Test-Path -Path "C:\Program Files\git\usr\bin\msys-iconv-2.dll"))
    {
        Log_Info "Git nohup.exe and associated DLLs installed and in correct place, continuing."
        $path_to_nohup_executables = "C:\Program Files\Git\usr\bin"
        $env:Path = "$path_to_nohup_executables;" + $env:Path
        Log_Debug "Set path to nohup to $path_to_nohup_executables;"
    }
    elseif ( (Get-Command "$Env:HOMEDRIVE$Env:HOMEPATH\AppData\Local\Programs\Git\usr\bin\nohup.exe" -ErrorAction SilentlyContinue) -And ( Test-Path -Path "$Env:HOMEDRIVE$Env:HOMEPATH\AppData\Local\Programs\Git\usr\bin\msys-2.0.dll") -And ( Test-Path -Path "$Env:HOMEDRIVE$Env:HOMEPATH\AppData\Local\Programs\Git\usr\bin\msys-iconv-2.dll") )
    {
        $path_to_nohup_executables = "$Env:HOMEDRIVE$Env:HOMEPATH\AppData\Local\Programs\Git\usr\bin"
        $env:Path = "$path_to_nohup_executables;" + $env:Path
        Log_Debug "Found nohup in user installed git location. Set path to nohup to $path_to_nohup_executables;"
        $downloadAndInstallPortableGit = "true"
        $softLinkTarget = "$Env:HOMEDRIVE$Env:HOMEPATH\AppData\Local\Programs\Git\usr\bin"
    }
    else
    {
        Log_Info "Nohup.exe and associated DLLs not found. Will download portable version"
        $path_to_nohup_executables = $null
        $softLinkTarget = $null
        $downloadAndInstallPortableGit = "true"
    }
}
$gitDownloadVersion = "2.39.2"
$gitDownloadUrl = "https://github.com/git-for-windows/git/releases/download/v" + $gitDownloadVersion + ".windows.1/PortableGit-" + $gitDownloadVersion + "-64-bit.7z.exe"

Log_Debug "downloadAndInstallPortableGit=$downloadAndInstallPortableGit"
# Download portable version of Git if some of the needed binaries were not found in the checks above
if ($downloadAndInstallPortableGit)
{
    Log_Debug "Will download Git as downloadAndInstallPortableGit=$downloadAndInstallPortableGit"
    Log_Debug "softLinkTarget=$softLinkTarget"

    if ($softLinkTarget -ne $null)
    {
        # Create soft-limk to existig user based git/usr/bin folder
        Log_Debug "Skipping download of portable Git and using existing Git in user folder instead"
    }
    else
    {
        Log_Debug "Proceeding to download and unpack portable Git ->  $gitDownloadUrl"
        curl.exe -L --progress-bar $gitDownloadUrl -o .\portable-git-archive.exe
        .\portable-git-archive.exe -o .\git -y
        $path_to_git_executable = "$PSScriptRoot\git\bin\git.exe"
        $path_to_sh_executable = "$PSScriptRoot\git\bin\sh.exe"
        $env:Path = "$PSScriptRoot\git\bin;" + $env:Path
        $env:Path = "$PSScriptRoot\git\usr\bin;" + $env:Path
        Log_Debug "Path: $env:Path"
        $softLinkTarget = "$PSScriptRoot\git\usr\bin"
        if (($softLinkTarget -ne $null) -Or ($softLinkTarget -ne ""))
        {
            # Create Directory & Symbolic Link
            Log_Debug "Creating directory path C:\Program Files\git\usr\ and symbolic link to $softLinkTarget"
            Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Unrestricted -Command New-Item -Path 'C:\Program Files\Git\usr' -ItemType Directory -ea 0; New-Item -ItemType SymbolicLink -Path 'C:\Program Files\Git\usr' -Name bin -Value `"$softLinkTarget`" -ea 0; pause" -Verb RunAs
            Log_Debug "Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Unrestricted -Command New-Item -Path `"C:\Program`` Files\Git\usr`" -ItemType Directory -ea 0; New-Item -ItemType SymbolicLink -Path `"C:\Program`` Files\Git\usr`" -Name `"bin`" -Value `"$softLinkTarget`" -ea 0; pause' -Verb RunAs"
        }
    }
}

# Determine absolute work and shared_workspace directory paths
$HOMEDIR_ABSOLUTE_PATH = "$PSScriptRoot\$JENKINS_HOME"
$JENKINS_HOME = $HOMEDIR_ABSOLUTE_PATH -replace "/","\"
Log_Debug "JENKINS_HOME: $JENKINS_HOME"
$SHARED_WORKSPACE_DIR_ABSOLUTE_PATH = "$PSScriptRoot\jenkins_shared_workspace"
$JENKINS_SHARED_WORKSPACE = $SHARED_WORKSPACE_DIR_ABSOLUTE_PATH -replace "/","\"
Log_Debug "JENKINS_SHARED_WORKSPACE: $JENKINS_SHARED_WORKSPACE"

if ( ! ( Test-Path -Path $JENKINS_HOME ) ) {
    New-Item -Path "$JENKINS_HOME" -ItemType "directory" -ea 0
}

# Versions that will be downloaded if already installed binaries not found
$composeDownloadVersion = "1.29.2"
$javaDownloadVersion = "11.0.3.7.1"
$jqDownloadVersion = "1.6"
$curlDownloadVersion = "7.84.0_9"
$jenkinsDownloadVersion = "2.332.2"

# Determine OS this script is running on and set appropriate download links and commands
Log_Info "Script running on Windows. Setting appropriate download links" | Blue
$javaInstallerUrl = "https://d3pxv6yz143wms.cloudfront.net/" + $javaDownloadVersion + "/amazon-corretto-" + $javaDownloadVersion + "-windows-x64.zip"
$jqInstallerUrl = "https://github.com/stedolan/jq/releases/download/jq-" + $jqDownloadVersion + "/jq-win64.exe"
$curlDownloadUrl = "https://curl.se/windows/dl-" + $curlDownloadVersion + "/curl-" + $curlDownloadVersion + "-win64-mingw.zip"
$jenkinsWarFileUrl = "https://get.jenkins.io/war-stable/" + $jenkinsDownloadVersion + "/jenkins.war"
$os = "windows"

Log_Debug "Set java download link to: " + $javaInstallerUrl
Log_Debug "Set jq download link to: " + $jqInstallerUrl
Log_Debug "Set Jenkins download link to: " + $jenkinsWarFileUrl

$minimalJqVersion = "1.5"

function Download-Tool {
    param ([string]$downloadUrl, [string]$webOutput)
    curl.exe -L --progress-bar $downloadUrl -o $webOutput
    If(!(test-path $webOutput)) {
        Log_Error "Download of $webOutput. Check your internet and try again"
        Exit
    } else {
        & .\$webOutput --version
    }
}

function Check-Tool
{
    param ([string]$toolExecutable, [string]$minimalVersion, [string]$downloadUrl)
    If (!(test-path .\$toolExecutable))
    {
        if (Get-Command $toolExecutable -ErrorAction SilentlyContinue)
        {
            $toolVersion = $( & $toolExecutable -v | Select-String '((?:\d{1,3}\.){2}\d{1,3})' | ForEach-Object { $_.Matches[0].Groups[1].Value } )
            if ($minimalVersion -gt $toolVersion)
            {
                Download-Tool $downloadUrl $toolExecutable
                $binary = ".\$toolExecutable"
            } else {
                $binary = $toolExecutable
            }
        } else {
            Download-Tool $downloadUrl $toolExecutable
            $binary = ".\$toolExecutable"
        }
    } else {
        $binary = ".\$toolExecutable"
    }
    Log_Debug "$binary"
    return $binary
}

$jqBinary = (Check-Tool jq.exe $minimalJqVersion $jqInstallerUrl)[1]
Log_Debug "jqBinary: $jqBinary"

# Install Java
$javaBinary = Get-ChildItem ./java -recurse -include "java.exe"
Log_Debug "Discovered java binary: `"$javaBinary`""

if (  ( $javaBinary -ne $null ) ) {
    Write-Host "Java Binary already present. Skipping Installation of Java"
} else {
    Log_Info "Downloading and installing to current directory under ./java"
    $webOutput = "amazon-corretto-windows-x64.zip"
    curl.exe -L --progress-bar $javaInstallerUrl -o .\$webOutput
    Log_Info "Executing... Expand-Archive -LiteralPath .\$webOutput .\java"
    Expand-Archive -LiteralPath .\$webOutput .\java
    $javaBinary = Get-ChildItem .\java -recurse -include "java.exe"
    Log_Debug "Java binary: $javaBinary"
    & $javaBinary -version
}

Exit

# Create shared workspace directory for Vagrant and Terraform jobs
$shared_workspace_base_directory_path = $JENKINS_SHARED_WORKSPACE
Log_Debug "shared_workspace_base_directory_path: $shared_workspace_base_directory_path"
$shared_workspace_directory_path = "$shared_workspace_base_directory_path\kx.as.code"
$git_root_path = $( & git rev-parse --show-toplevel )

if ( ( Test-Path $shared_workspace_directory_path -PathType Container ) ) {
    if ( ! (Get-Item "$shared_workspace_directory_path").LinkType -eq "SymbolicLink" ) {
        Log_Error "Seems there is a kx.as.code directory where a symbolic link was expected (under $shared_workspace_base_directory_path). Try deleting it and re-running this script"
        Exit
    }
}

if ( ! ( Test-Path -Path $shared_workspace_directory_path ) )
{
    $adminUserRole = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    Log_Debug "Has this script been started with admin priviliges? --> $adminUserRole"
    if ( -not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator") ) {
        Log_Info "In a moment you will be asked to approve a task that requires administrative privileges"
        Log_Info "The task is to create a symbolic link in the shared workspace to the Git repository for the Jenkins jobs to use"
        Log_Info "The impact of not approving this, is that the Jenkins jobs will not work, as they will not have access to the KX.AS.CODE Git repository"
        Log_Info "--> Hit <enter> to continue or <ctrl-c> to cancel and exit this script"
        pause
    }
    Log_Debubg "Creating workspace path -> $shared_workspace_base_directory_path"
    New-Item -Path "$shared_workspace_base_directory_path" -ItemType "directory" -ea 0
    $git_root_path = $( & git rev-parse --show-toplevel )
    Log_Debug "git_root_path: $git_root_path"
    Log_Debug "Start-Process PowerShell -ArgumentList `"-NoProfile -ExecutionPolicy Unrestricted -Command New-Item -ItemType SymbolicLink -Path $shared_workspace_base_directory_path -Name 'kx.as.code' -Value $git_root_path -ea 0; pause`" -Verb RunAs"
    Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Unrestricted -Command New-Item -ItemType SymbolicLink -Path $shared_workspace_base_directory_path -Name 'kx.as.code' -Value $git_root_path -ea 0; pause" -Verb RunAs
    for ($counter = 1; $counter -le 6; $counter++ ) {
        # Checking that the Symbolic link was created
        if ( -not ( & dir $shared_workspace_base_directory_path -force | ?{$_.LinkType} | select FullName,LinkType,Target ) ) {
            Log_Info "The kx.as.code symbolic link under $shared_workspace_base_directory_path does not exist. Will check 5 times -> [Check #$counter]"
            if ( ( Test-Path $shared_workspace_directory_path -PathType Container ) ) {
                Log_Error "Seems there is a kx.as.code directory where a symbolic link was expected. Try deleting it and re-running this script"
                Exit
            }
        } else {
           Log_Info "Found the kx.as.code symbolic link under $shared_workspace_base_directory_path. Continuing..."
            break
        }
        Start-Sleep -Seconds 1
    }
}

# Download and update Jenkins WAR file with needed plugins
if (!(test-path .\jenkins.war)) {
    # Download Jenkins WAR file
    Log_Info "Downloading Jenkins WAR file..."
    curl.exe -L --progress-bar $jenkinsWarFileUrl -o jenkins.war
}

# Bypass Jenkins setup wizard
if (!(test-path $JENKINS_HOME\jenkins.install.UpgradeWizard.state)) {
    echo "$jenkinsDownloadVersion" > $JENKINS_HOME\jenkins.install.UpgradeWizard.state
}

# Bypass Jenkins setup wizard
if (!(test-path $JENKINS_HOME\jenkins.install.InstallUtil.lastExecVersion)) {
    echo "$jenkinsDownloadVersion" > $JENKINS_HOME\jenkins.install.InstallUtil.lastExecVersion
}

# Replace mustache variables in job config.xml files
New-Item -Path "$JENKINS_HOME\jobs" -Name "logfiles" -ItemType "directory"
Copy-Item -Path ".\initial-setup\*" -Destination "$JENKINS_HOME\" -Recurse -Force
Get-ChildItem "$JENKINS_HOME\jobs" -Recurse -Filter config.xml |
Foreach-Object {
    Log_Info "Replacing placeholders in job XML definition file $(Write-Output $_.FullName)"
    $filename = $_.FullName
    $tempFilePath = "$filename.tmp"
    select-string -path $_.FullName -pattern '(?<={{)(.*?)(?=}})' -allmatches  |
            foreach-object {$_.matches} |
            foreach-object {$_.groups[1].value} |
            Select-Object -Unique |
            ForEach-Object {
                (Get-Content -path $filename -Raw) -replace "{{$((Get-Variable -Name "$($_)").Name)}}","$((Get-Variable -Name "$($_)").Value)" | Set-Content -Path $tempFilePath
                Move-Item -Path $tempFilePath -Destination $filename -Force
            }
            Move-Item -Path $tempFilePath -Destination $filename -Force
}

# Replace mustache variables in Jenkins config files
Get-ChildItem "$JENKINS_HOME\" -Filter *.xml |
            Foreach-Object {
                $filename =  $_.FullName
                Log_Info "Replacing placeholders in XML configuration file $filename"
                $tempFilePath = "$filename.tmp"
                select-string -path $filename -pattern '(?<={{)(.*?)(?=}})' -allmatches  |
                        foreach-object { $_.matches } |
                        foreach-object { $_.groups[1].value } |
                        Select-Object -Unique |
                        ForEach-Object {
                            (Get-Content -path $filename -Raw) -replace "{{$( (Get-Variable -Name "$( $_ )").Name )}}", "$( (Get-Variable -Name "$( $_ )").Value )" | Set-Content -Path $tempFilePath
                            Move-Item -Path $tempFilePath -Destination $filename -Force
                        }
                Move-Item -Path $tempFilePath -Destination $filename -Force
            }

# Check if plugin manager already downloaded or not
if (!(test-path .\jenkins-plugin-manager.jar)) {
    # Install Jenkins Plugins
    $jenkinsPluginManagerVersion = "2.12.8"
    Log_Indo "Downloading Jenkins Plugin Manager..."
    curl.exe -L --progress-bar https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/$jenkinsPluginManagerVersion/jenkins-plugin-manager-$jenkinsPluginManagerVersion.jar -o .\jenkins-plugin-manager.jar
}

# Download plugins if not yet installed
if (!(Test-Path -Path $JENKINS_HOME\plugins\*)) {
    Log_Info "Downloading Jenkins plugins..." | Blue
    Start-Process -FilePath $javaBinary -Wait -NoNewWindow -ArgumentList "-jar", "./jenkins-plugin-manager.jar", "--war", "./jenkins.war", "--plugin-download-directory", "$JENKINS_HOME/plugins", "--plugin-file", "./initial-setup/plugins.txt", "--plugins delivery-pipeline-plugin:1.3.2", "deployit-plugin"
} else {
    Log_Info "Jenkins plugins already downloaded"
}

# Set jenkins_home and start Jenkins
# Start manually for debugging with Start-Process -FilePath .\java\jdk11.0.3_7\bin\java.exe -ArgumentList "-jar", ".\jenkins.war", "--httpListenAddress=127.0.0.1", "--httpPort=8081"
[Environment]::SetEnvironmentVariable("JENKINS_HOME", "${PWD}\jenkins_home")
$env:Path = "C:\Program Files\Git\bin;C:\Program Files\Git\usr\bin;$git_root_path;" + $env:Path

# Start Jenkins
$javaProcess = Start-Process -FilePath $javaBinary -ArgumentList "-jar", ".\jenkins.war", "--httpListenAddress=$jenkins_listen_address", "--httpPort=$jenkins_server_port" -PassThru
$javaProcess.WaitForInputIdle()

# Write Jenkins Pid file to file as needed later to reliably stop Jenkins if script called with -s
Write-Output $javaProcess.id | Out-File -FilePath .\jenkinsPid

$jenkinsUrl = "http://localhost:${jenkins_server_port}"

# Check Jenkins URL is reachable for downloading jenkins-cli.jar
try
{
    $webRequest = (Invoke-WebRequest -Uri $jenkinsUrl/view/Status/ -UseBasicParsing -DisableKeepAlive).StatusCode
} catch {
    $_.Exception.Response.StatusCode.Value__
}
do
{
    try {
        $webRequest = (Invoke-WebRequest -Uri $jenkinsUrl/view/Status/ -UseBasicParsing -DisableKeepAlive).StatusCode
        Log_Info "$jenkinsUrl/view/Status/ [RC=$webRequest]"
    } catch {
        $rc = $_.Exception.Response.StatusCode.Value__
        Log_Warn "$jenkinsUrl/view/Status/ [RC=$rc]"
    }
    if($webRequest -ne "200"){
        Start-Sleep -Seconds 15
    }
}while($webRequest -ne "200")

# Download Jenkins CLI from started Jenkins
curl.exe -L --progress-bar $jenkinsUrl/jnlpJars/jenkins-cli.jar -o .\jenkins-cli.jar

# Get Jenkins crumb for authenticating subsequent requests
$jenkinsCrumb = (curl.exe -s --cookie-jar ./cookies -u admin:admin $jenkinsUrl/crumbIssuer/api/json) | ConvertFrom-Json | Select-Object -expand "crumb"

# Generate secrets file and hash
.\generateSecretsFile.ps1 -r

# Read hash created by above script
$hash = Get-Content -Path .\.hash -TotalCount 1
Log_Debug "Extracted hash from previous script call: *$hash*" "DarkYellow"

# Import credential xml files into Jenkins
Get-ChildItem "$JENKINS_HOME\" -Filter credential_*.xml |
        Foreach-Object {
            Log_Debug "Replacing parameters in credential XML defintion file $(Write-Output $_.FullName)"
            $filename = $_.FullName
            Log_Info "Attempting to upload $filename to Jenkins"
            try
            {
                $content = Get-Content -Path $filename -Raw
                $xml = [xml](Get-Content $filename)
                $credentialId = $xml.SelectNodes("//id").Innertext
                # Delete credential in order to update/recreate it in next step
                # Check if crdential exists and delete if it does
                $httpResponseCode = (curl.exe -X GET --cookie .\cookies -H "Jenkins-Crumb: $jenkinsCrumb" -u admin:admin $jenkinsUrl/credentials/store/system/domain/_/credential/$credentialId -L -s -o /dev/null -w "%{http_code}")
                Log_Debug "Received httpResponseCode = $httpResponseCode, from check if credential $credentialId exists or not"
                if ( $httpResponseCode -eq "200" )
                {
                    Log_Debug "curl.exe -X POST --cookie .\cookies -H `"Jenkins-Crumb: $jenkinsCrumb`" -u admin:admin $jenkinsUrl/credentials/store/system/domain/_/credential/$credentialId/doDelete"
                    Log_Info "Deleting credential with id $credentialId so it can be recreated"
                    curl.exe -X POST --cookie .\cookies -H "Jenkins-Crumb: $jenkinsCrumb" `
                        -u admin:admin `
                        $jenkinsUrl/credentials/store/system/domain/_/credential/$credentialId/doDelete
                } else {
                    Log_Debug "Nothing to delete, as credential $credentialId did not exit yet" "DarkYellow"
                }
                # Create credential
                Write-Output $content | & $javaBinary -jar .\jenkins-cli.jar -s $jenkinsUrl create-credentials-by-xml system::system::jenkins _
                Remove-Item -Force -Path $filename
            } catch {
                Log_Debug "Variable replacements for $filename failed. Please make sure the XML credential for $filename is valid"
                Write-Output "$javaBinary -jar .\jenkins-cli.jar -s $jenkinsUrl create-credentials-by-xml system::system::jenkins _"
            }
        }

# Delete credential in order to update/recreate it in next step
$httpResponseCode = (curl.exe -X GET --cookie .\cookies -H "Jenkins-Crumb: $jenkinsCrumb" -u admin:admin $jenkinsUrl/credentials/store/system/domain/_/credential/VM_CREDENTIALS_FILE -L -s -o /dev/null -w "%{http_code}")
Log_Debug "Received httpResponseCode = $httpResponseCode, from check if credential VM_CREDENTIALS_FILE exists or not"
if ( $httpResponseCode -eq "200" )
{
    Log_Debug "curl.exe -X POST --cookie .\cookies -H `"Jenkins-Crumb: $jenkinsCrumb`" -u admin:admin $jenkinsUrl/credentials/store/system/domain/_/credential/VM_CREDENTIALS_FILE/doDelete"
    curl.exe -X POST --cookie .\cookies -H "Jenkins-Crumb: $jenkinsCrumb" `
    -u admin:admin `
     $jenkinsUrl/credentials/store/system/domain/_/credential/VM_CREDENTIALS_FILE/doDelete
} else {
    Log_Debug "Nothing to delete, as credential VM_CREDENTIALS_FILE did not exit yet" "DarkYellow"
}

# Post encrypted file to Jenkins as a credential
curl.exe -X POST --cookie .\cookies -H "Jenkins-Crumb: $jenkinsCrumb" `
    -u admin:admin `
    -F securedCredentials=@.\.vmCredentialsFile `
    -F "json={\`"\`": \`"4\`", \`"credentials\`": { \`"file\`": \`"securedCredentials\`", \`"id\`": \`"VM_CREDENTIALS_FILE\`", \`"description\`": \`"KX.AS.CODE credentials\`", \`"stapler-class\`": \`"org.jenkinsci.plugins.plaincredentials.impl.FileCredentialsImpl\`", \`"`$class\`": \`"org.jenkinsci.plugins.plaincredentials.impl.FileCredentialsImpl\`"}}" `
    $jenkinsUrl/credentials/store/system/domain/_/createCredentials

Log_Info "Congratulations! Jenkins for KX.AS.CODE is successfully configured and running. Access Jenkins via the following URL: " "Green"
Log_Info "$jenkinsUrl/job/KX.AS.CODE_Launcher/build?delay=0sec" "Blue"
