# Define ansi colours
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

$ErrorActionPreference = "SilentlyContinue"

# Settings that will be used for provisioning Jenkins, including credentials etc
if ( ! ( Test-Path -Path ".\jenkins.env" ) )
{
    Write-Output "- [ERROR] Please create the jenkins.env file in the base-vm/build/jenkins folder by copying the template (jenkins.env.template --> jenkins.env), and adding/amending the values" | Red
    Exit
}

if ( $args.count -gt 1 ) {
    Write-Output "- [ERROR] You must provide one parameter only" | Red
    Exit
}

Remove-Item -Force -Path 'jenkins.env.ps1'
Foreach ($line in (Get-Content -Path "jenkins.env" | Where-Object {$_ -notmatch '^#.*'} | Where-Object {$_ -notmatch '^$'}))
{
    # Created for sourcing for this script
    $line -replace '^', '$' | Add-Content -Path 'jenkins.env.ps1'
}

. ./jenkins.env.ps1

# Checking Windows specific pre-requisites
# Git bash must be installed and available, else "sh" will not work in the Jenkins pipeline
if (Get-Command "c:\Program Files\Git\bin\sh.exe" -ErrorAction SilentlyContinue)
{
    if ( Get-Command "sh.exe" -ErrorAction SilentlyContinue )
    {
        Write-Output "sh.exe on path. All good" | Green
        $env:Path += ";c:\Program Files\Git\bin\;c:\Program Files\Git\usr\bin\"
    } else
    {
        Write-Output "sh.exe not on path. Adding it"
        $env:Path += ";c:\Program Files\Git\bin\;c:\Program Files\Git\usr\bin\"
        if ( Get-Command "sh.exe" -ErrorAction SilentlyContinue )
        {
            Write-Output "sh.exe is now accessible on path. All good" | Green
        } else {
            Write-Output "sh.exe is still not accessible on the path. Check that Git Bash is installed correctly and try again" | Red
            Exit
        }
    }
}

# Create git usr/bin directory if not existing
if ( ! ( Test-Path -Path "C:\Program Files\git\usr\bin" ) )
{
    New-Item -ItemType "directory" -Path "C:\Program Files\git\usr\bin"
    # Check links are created so Jenkins slave has access to nohup
    if ( ! ( Test-Path -Path "C:\Program Files\git\usr\bin\nohup.exe" ) ) {
        & mklink "C:\Program Files\Git\bin\nohup.exe" "C:\Program Files\Git\usr\bin\nohup.exe"
    }
    if ( ! ( Test-Path -Path "C:\Program Files\git\usr\bin\msys-2.0.dll" ) ) {
        & mklink "C:\Program Files\Git\bin\msys-2.0.dll" "C:\Program Files\Git\usr\bin\msys-2.0.dll"
    }
    if ( ! ( Test-Path -Path "C:\Program Files\git\usr\bin\msys-iconv-2.dll" ) ) {
        & mklink "C:\Program Files\Git\bin\msys-iconv-2.dll" "C:\Program Files\Git\usr\bin\msys-iconv-2.dll"
    }
}

if ( $args[0] ) {
    switch ( $args[0] )
    {
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
              -d  [d]estroy and rebuild Jenkins environment. All history is also deleted
              -f  [f]ully destroy and rebuild, including ALL built images and ALL KX.AS.CODE virtual machines!
              -h  [h]elp me and show this help text
              -r  [r]ecreate Jenkins jobs with updated parameters. Will keep history
              -s  [s]op the Jenkins build environment
              -u  [u]ninstall and give me back my disk space`n"
            Exit
        }
        default {
            Write-Output "[ERROR] Invalid option: $($args[0]). Call .\launchLocalBuildEnvironment.ps1 -h to display help text`n" | Red
            .\launchLocalBuildEnvironment.ps1 -h
        }
    }
}


# Determine absolute work and shared_workspace directory paths
$HOMEDIR_ABSOLUTE_PATH = "$PSScriptRoot\$JENKINS_HOME"
$JENKINS_HOME = $HOMEDIR_ABSOLUTE_PATH -replace "/","\"
Write-Output "- [INFO] JENKINS_HOME: $JENKINS_HOME"

if ( ! ( Test-Path -Path $JENKINS_HOME ) ) {
    New-Item -Path "$JENKINS_HOME" -ItemType "directory" -ea 0
}


# Determine absolute work and shared_workspace directory paths
$SHARED_WORKSPACE_DIR_ABSOLUTE_PATH = "$PSScriptRoot\jenkins_shared_workspace"
$JENKINS_SHARED_WORKSPACE = $SHARED_WORKSPACE_DIR_ABSOLUTE_PATH -replace "/","\"
Write-Output "- [INFO] JENKINS_SHARED_WORKSPACE: $JENKINS_SHARED_WORKSPACE"


if ( $override_action -eq "recreate" -Or $override_action -eq "destroy" -Or $override_action -eq "fully-destroy" -Or $override_action -eq "uninstall" ) {
    $Input = Read-Host -Prompt "$areYouSureQuestion [Y/N]"
    Write-Output $Input
    if (  $Input -eq "Y" ) {
        Write-Output "- [INFO] OK! Proceeding to ${override_action} the KX.AS.CODE Jenkins environment"
        Write-Output "- [INFO] Deleting Jenkins jobs..." | Red
        Get-ChildItem "$JENKINS_HOME\jobs" -Recurse -Filter config.xml |
        Foreach-Object {
            Remove-Item -Force -Path  $_.FullName
        }
        Write-Output "- [INFO] Jenkins jobs deleted" | Red
        if ( $override_action -eq "destroy" -Or $override_action -eq "fully-destroy" -Or $override_action -eq "uninstall" )
        {
            Write-Output "- [INFO] Deleting jenkins_home directory..." | Red
            Remove-Item -Recurse -Force -Path $JENKINS_HOME
            Write-Output "- [INFO] jenkins_home deleted" | Red
            if ($override_action -eq "fully-destroy")
            {
                Write-Output "- [INFO] Deleting shared_workspace directory..." | Red
                Remove-Item -Path -Recursive -Force $JENKINS_SHARED_WORKSPACE
                Write-Output "- [INFO] shared_workspace deleted" | Red
            }
            Write-Output "- [INFO] Deleting downloaded tools..." | Red
            Remove-Item -Force -Path ./jq.exe
            Remove-Item -Force -Recurse -Path ./java
            Remove-Item -Force -Path ./jenkins-cli.jar
            Write-Output "- [INFO] Downloaded tools deleted" | Red
        }
        if ( $override_action -eq "uninstall" )
        {
            Write-Output "Uninstall complete" | Red
            Exit
        }
    } else {
        Write-Output "Cancelling request to $override_action as response was $Input"
    }
}

# Versions that will be downloaded if already installed binaries not found
$composeDownloadVersion = "1.29.2"
$javaDownloadVersion = "11.0.3.7.1"
$jqDownloadVersion = "1.6"
$jenkinsDownloadVersion = "2.332.2"

# Determine OS this script is running on and set appropriate download links and commands
Write-Output "- [INFO] Script running on Windows. Setting appropriate download links" | Blue
$javaInstallerUrl = "https://d3pxv6yz143wms.cloudfront.net/" + $javaDownloadVersion + "/amazon-corretto-" + $javaDownloadVersion + "-windows-x64.zip"
$jqInstallerUrl = "https://github.com/stedolan/jq/releases/download/jq-" + $jqDownloadVersion + "/jq-win64.exe"
$jenkinsWarFileUrl = "https://get.jenkins.io/war-stable/" + $jenkinsDownloadVersion + "/jenkins.war"
$os = "windows"

Write-Output "- [INFO] Set java download link to: " + $javaInstallerUrl
Write-Output "- [INFO] Set jq download link to: " + $jqInstallerUrl
Write-Output "- [INFO] Set Jenkins download link to: " + $jenkinsWarFileUrl

$minimalJqVersion = "1.5"

function Download-Tool {
    param ([string]$downloadUrl, [string]$webOutput)
    Invoke-WebRequest $downloadUrl -OutFile $webOutput
    If(!(test-path $webOutput)) {
        Write-Output "Download of $webOutput. Check your internet and try again" | Red
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
    Write-Output $binary
    return $binary
}

$jqBinary = (Check-Tool jq.exe $minimalJqVersion $jqInstallerUrl)[1]
Write-Output "jqBinary: $jqBinary"

$javaBinary = Get-ChildItem .\java -recurse -include "java.exe"
Write-Output "Discovered java binary: `"$javaBinary`""

# Install Java
if ( ! $javaBinary ) {
    if (!(Get-Command java.exe -ErrorAction SilentlyContinue)) {
        Write-Output "Java not found. Downloading and installing to current directory under ./java" | Orange
        $webOutput = "amazon-corretto-windows-x64.zip"
        Invoke-WebRequest $javaInstallerUrl -OutFile .\$webOutput
        Write-Output "Executing... Expand-Archive -LiteralPath .\$webOutput .\java"
        Expand-Archive -LiteralPath .\$webOutput .\java
        $javaBinary = Get-ChildItem .\java -recurse -include "java.exe"
        Write-Output "Java binary: $javaBinary"
        & $javaBinary -version
    }
    else
    {
        $javaBinary = "java.exe"
        Write-Output "Java binary: $javaBinary"
        & $javaBinary -version
    }
}

# Create shared workspace directory for Vagrant and Terraform jobs
$shared_workspace_base_directory_path = $JENKINS_SHARED_WORKSPACE
$shared_workspace_directory_path = "$shared_workspace_base_directory_path\kx.as.code"
$git_root_path = $( & git rev-parse --show-toplevel )

if ( ( Test-Path $shared_workspace_directory_path -PathType Container ) ) {
    if ( ! (Get-Item "$shared_workspace_directory_path").LinkType -eq "SymbolicLink" ) {
    Write-Output "Seems there is a kx.as.code directory where a symbolic link was expected (under $shared_workspace_base_directory_path). Try deleting it and re-running this script" | Red
    exit
    }
}

if ( ! ( Test-Path -Path $shared_workspace_directory_path ) )
{
    $adminUserRole = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    Write-Output "Is admin? --> $adminUserRole"
    if ( -not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator") ) {
        Write-Output "In a moment you will be asked to approve a task that requires administrative privileges" | Orange
        Write-Output "The task is to create a symbolic link in the shared workspace to the Git repository for the Jenkins jobs to use" | Orange
        Write-Output "The impact of not approving this, is that the Jenkins jobs will not work, as they will not have access to the KX.AS.CODE Git repository" | Orange
        Write-Output "--> Hit <enter> to continue or <ctrl-c> to cancel and exit this script" | Orange
        pause
    }
    Write-Output "Creating workspace path"
    New-Item -Path "$shared_workspace_base_directory_path" -ItemType "directory" -ea 0
    powershell.exe -NoProfile -ExecutionPolicy Unrestricted -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Unrestricted -Command New-Item -Path $shared_workspace_directory_path -ItemType SymbolicLink -Value $git_root_path' -Verb RunAs}";
    for ($counter = 1; $counter -le 6; $counter++ ) {
        # Checking that the Symbolic link was created
        if ( -not ( & dir $shared_workspace_base_directory_path -force | ?{$_.LinkType} | select FullName,LinkType,Target ) ) {
            Write-Output "The kx.as.code symbolic link under $shared_workspace_base_directory_path does not exist. Will check 5 times -> [Check #$counter]" | Orange
            if ( ( Test-Path $shared_workspace_directory_path -PathType Container ) ) {
                Write-Output "Seems there is a kx.as.code directory where a symbolic link was expected. Try deleting it and re-running this script"
                exit
            }
        } else {
            Write-Output "Found the kx.as.code symbolic link under $shared_workspace_base_directory_path. Continuing..." | Green
            break
        }
        Start-Sleep -Seconds 1
    }
}

# Download and update Jenkins WAR file with needed plugins
if (!(test-path .\jenkins.war)) {
    # Download Jenkins WAR file
    Write-Output "Downloading Jenkins WAR file..." | Blue
    Invoke-WebRequest $jenkinsWarFileUrl -OutFile jenkins.war
}

# Check if plugin manager already downloaded or not
if (!(test-path .\jenkins-plugin-manager.jar)) {
    # Install Jenkins Plugins
    $jenkinsPluginManagerVersion = "2.11.1"
    Write-Output "Downloading Jenkins Plugin Manager..." | Blue
    Invoke-WebRequest -Uri https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/$jenkinsPluginManagerVersion/jenkins-plugin-manager-$jenkinsPluginManagerVersion.jar -OutFile .\jenkins-plugin-manager.jar
}

# Download plugins if not yet installed
if (!(Test-Path -Path $JENKINS_HOME\plugins\*)) {
    Write-Output "Downloading Jenkins plugins..." | Blue
    Start-Process -FilePath $javaBinary -Wait -NoNewWindow -ArgumentList "-jar", "./jenkins-plugin-manager.jar", "--war", "./jenkins.war", "--plugin-download-directory", "$JENKINS_HOME/plugins", "--plugin-file", "./initial-setup/plugins.txt", "--plugins delivery-pipeline-plugin:1.3.2", "deployit-plugin"
} else {
    Write-Output "Jenkins plugins already downloaded" | Green
}

# Bypass Jenkins setup wizard
if (!(test-path $JENKINS_HOME\jenkins.install.UpgradeWizard.state)) {
    echo "$jenkinsDownloadVersion" > $JENKINS_HOME\jenkins.install.UpgradeWizard.state
}

# Bypass Jenkins setup wizard
if (!(test-path $JENKINS_HOME\jenkins.install.InstallUtil.lastExecVersion)) {
    echo "$jenkinsDownloadVersion" > $JENKINS_HOME\jenkins.install.InstallUtil.lastExecVersion
}

# Generate KX.AS.CODE start job --> merge active choice parameters into start dsl job template
$start_job_file = "initial-setup\jobs\KX.AS.CODE_Launcher\config.xml"
$start_job_template_file = "initial-setup\jobs\KX.AS.CODE_Launcher\config.xml_template"

Copy-Item $start_job_template_file $start_job_file
Write-Output $start_job_file
$jobContent = Get-Content $start_job_file -Encoding Default -Raw
Write-Content "Test 1"
Get-Content $start_job_file -Encoding UTF8 | Select-String '(?<=@\{)(.+)(?=\})' | ForEach-Object {
    $filename = Write-Output $_.Matches[0].Groups[1].Value
    Write-Output "initial-setup/active_choice_parameters/$filename"
    dir "initial-setup/active_choice_parameters/$filename"
    $groovyContent = (Get-Content initial-setup/active_choice_parameters/$filename -Encoding Default -Raw).replace('&&','&amp;&amp;').replace('&quot;','&amp;quot;').replace("`'",'&apos;').replace('"','&quot;').replace('<','&lt;').replace('>','&gt;')
    #Write-Output "Content: " + $groovyContent
    $placeholderToReplace = '@{' + $_.Matches[0].Groups[1].Value + '}'
    $jobContent = $jobContent.replace($placeholderToReplace, $groovyContent)
    Write-Output "################################################"
    #Write-Output "################################################" + $jobContent
    Write-Output "################################################"
    Write-Output "$placeholderToReplace"
}
#Write-Output "Merged Content: " + $jobContent
Write-Output $jobContent | Out-File $start_job_file -Encoding Default

#exit

# Replace mustache variables in job config.xml files
New-Item -Path "$JENKINS_HOME\jobs" -Name "logfiles" -ItemType "directory"
Copy-Item -Path ".\initial-setup\*" -Destination "$JENKINS_HOME\" -Recurse -Force
Get-ChildItem "$JENKINS_HOME\jobs" -Recurse -Filter config.xml |
Foreach-Object {
    Write-Output "Replacing parameters in job XML defintion file $(Write-Output $_.FullName)"
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
            (Get-Content -path $filename -Raw) -replace "base-vm/build/jenkins/","base-vm\build\jenkins\" | Set-Content -Path $tempFilePath
            Move-Item -Path $tempFilePath -Destination $filename -Force

}

# Set jenkins_home and start Jenkins
# Start manually for debugging with Start-Process -FilePath .\java\jdk11.0.3_7\bin\java.exe -ArgumentList "-jar", ".\jenkins.war", "--httpListenAddress=127.0.0.1", "--httpPort=8081"
[Environment]::SetEnvironmentVariable("JENKINS_HOME", "${PWD}\jenkins_home")
# TODO - Test Git paths on line below. Currently hardcoded for debugging
$env:Path += ";C:/Program Files/Git/bin;C:/Program Files/Git/usr/bin;C:/Git/kx.as.code_test"
Start-Process -FilePath $javaBinary -ArgumentList "-jar", ".\jenkins.war", "--httpListenAddress=$jenkins_listen_address", "--httpPort=$jenkins_server_port"

$jenkinsUrl = "http://${jenkins_listen_address}:${jenkins_server_port}"
Write-Output "jenkinsUrl: `"$jenkinsUrl"`"
Write-Output "Discovered java binary: `"$javaBinary`""

Write-Output "JENKINS_SHARED_WORKSPACE: `"$JENKINS_SHARED_WORKSPACE"`"
Write-Output "JENKINS_HOME: `"$JENKINS_HOME"`"
Write-Output "PSScriptRoot: `"$PSScriptRoot"`"

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
        Write-Output "$jenkinsUrl/view/Status/ [RC=$webRequest]" | Green
    } catch {
        $rc = $_.Exception.Response.StatusCode.Value__
        Write-Output "$jenkinsUrl/view/Status/ [RC=$rc]"
    }
    if($webRequest -ne "200"){
        Start-Sleep -Seconds 15
    }
}while($webRequest -ne "200")

Invoke-WebRequest -Uri $jenkinsUrl/jnlpJars/jenkins-cli.jar -OutFile .\jenkins-cli.jar

# Replace mustache variables in credential xml files
Get-ChildItem "$JENKINS_HOME\" -Filter credential_*.xml |
        Foreach-Object {
            Write-Output "Replacing parameters in credential XML defintion file $(Write-Output $_.FullName)"
            $filename = $_.FullName
            select-string -path $_.FullName -pattern '(?<={{)(.*?)(?=}})' -allmatches  |
                    foreach-object {$_.matches} |
                    foreach-object {$_.groups[1].value} |
                    Select-Object -Unique |
                    ForEach-Object {
                        (Get-Content -path $filename -Raw) -replace "{{$((Get-Variable -Name "$($_)").Name)}}","$((Get-Variable -Name "$($_)").Value)" | Set-Content -Path $tempFilePath
                        Move-Item -Path $tempFilePath -Destination $filename -Force
                    }
            Write-Output "Variable replacements for $filename succeeded" | Green
            try
            {
                $content = Get-Content -Path $filename -Raw
                Write-Output $content | & $javaBinary -jar .\jenkins-cli.jar -s $jenkinsUrl create-credentials-by-xml system::system::jenkins _
                Remove-Item -Force -Path $filename
            } catch {
                Write-Output "Variable replacements for $filename failed. Please make sure the XML credential for $filename is valid" | Red
                Write-Output "$javaBinary -jar .\jenkins-cli.jar -s $jenkinsUrl create-credentials-by-xml system::system::jenkins _" | Red
            }
        }

Write-Output "- [INFO] Congratulations! Jenkins for KX.AS.CODE is successfully configured and running. Access Jenkins via the following URL: " | Green
Write-Output "- ${jenkinsUrl}/job/KX.AS.CODE_Launcher/build?delay=0sec" | Blue