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
    process { Write-Host $_ -ForegroundColor Orange }
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
$firstTwoChars = $JENKINS_HOME.Substring(0,2)
$secondChar = $JENKINS_HOME.Substring(1,1)
$firstChar = $JENKINS_HOME.Substring(0,1)
if ( $firstTwoChars -eq ".\" ) {
    $HOMEDIR_ABSOLUTE_PATH = $JENKINS_HOME.Substring(2)
    $HOMEDIR_ABSOLUTE_PATH = "$PSScriptRoot\$HOMEDIR_ABSOLUTE_PATH"
}
elseif ( $secondChar -eq ":" )
{
    $HOMEDIR_ABSOLUTE_PATH = $JENKINS_HOME
}
else
{
    $HOMEDIR_ABSOLUTE_PATH = "$PSScriptRoot\$JENKINS_HOME"

}
$JENKINS_HOME = $HOMEDIR_ABSOLUTE_PATH -replace "/","\"


# Determine absolute work and shared_workspace directory paths
$firstTwoChars = $WORKING_DIRECTORY.Substring(0,2)
$secondChar = $WORKING_DIRECTORY.Substring(1,1)
$firstChar = $WORKING_DIRECTORY.Substring(0,1)
if ( $firstTwoChars -eq ".\" ) {
    $WORKDIR_ABSOLUTE_PATH = $WORKING_DIRECTORY.Substring(2)
    $WORKDIR_ABSOLUTE_PATH = "$PSScriptRoot\$WORKDIR_ABSOLUTE_PATH"
}
elseif ( $secondChar -eq ":" )
{
    $WORKDIR_ABSOLUTE_PATH = $WORKING_DIRECTORY
}
else
{
    $WORKDIR_ABSOLUTE_PATH = "$PSScriptRoot\$WORKING_DIRECTORY"

}
$WORKING_DIRECTORY = $WORKDIR_ABSOLUTE_PATH -replace "/","\"


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
        Write-Output "- [INFO] Deleting Docker container..." | Red
        docker rm -f jenkins
        Write-Output "- [INFO] Docker container deleted" | Red
        if ( $override_action -eq "destroy" -Or $override_action -eq "fully-destroy" -Or $override_action -eq "uninstall" )
        {
            Write-Output "- [INFO] Deleting Jenkins image..." | Red
            docker rmi "$( docker images $kx_jenkins_image -q )"
            Write-Output "- [INFO] Docker image deleted" | Red
            Write-Output "- [INFO] Deleting jenkins_home directory..." | Red
            Remove-Item -Recurse -Force -Path $JENKINS_HOME
            Write-Output "- [INFO] jenkins_home deleted" | Red
            if ($override_action -eq "fully-destroy")
            {
                Write-Output "- [INFO] Deleting jenkins_remote directory..." | Red
                Remove-Item -Path -Recursive -Force $WORKING_DIRECTORY
                Write-Output "- [INFO] jenkins_remote deleted" | Red
            }
            Write-Output "- [INFO] Deleting downloaded tools..." | Red
            Remove-Item -Force -Path ./jq.exe
            Remove-Item -Force -Recurse -Path ./java
            Remove-Item -Force -Path ./agent.jar
            Remove-Item -Force -Path ./jenkins-cli.jar
            Remove-Item -Force -Path ./docker-compose.exe
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

# Determine OS this script is running on and set appropriate download links and commands
Write-Output "- [INFO] Script running on Windows. Setting appropriate download links" | Blue
$dockerComposeInstallerUrl = "https://github.com/docker/compose/releases/download/" + $composeDownloadVersion + "/docker-compose-Windows-x86_64.exe"
$javaInstallerUrl = "https://d3pxv6yz143wms.cloudfront.net/" + $javaDownloadVersion + "/amazon-corretto-" + $javaDownloadVersion + "-windows-x64.zip"
$jqInstallerUrl = "https://github.com/stedolan/jq/releases/download/jq-" + $jqDownloadVersion + "/jq-win64.exe"
$os = "windows"

Write-Output "- [INFO] Set docker-compose download link to: " + $dockerComposeInstallerUrl
Write-Output "- [INFO] Set java download link to: " + $javaInstallerUrl
Write-Output "- [INFO] Set jq download link to: " + $jqInstallerUrl

$minimalComposeVersion = "1.25.0"
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

$dockerComposeBinary = (Check-Tool docker-compose.exe $minimalComposeVersion $dockerComposeInstallerUrl)[1]
$jqBinary = (Check-Tool jq.exe $minimalJqVersion $jqInstallerUrl)[1]

Write-Output "dockerComposeBinary: $dockerComposeBinary"
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
$shared_workspace_base_directory_path = "$WORKING_DIRECTORY\workspace\shared_workspace"
$shared_workspace_directory_path = "$shared_workspace_base_directory_path\kx.as.code"
$git_root_path = git rev-parse --show-toplevel

if ( ! ( Test-Path -Path $shared_workspace_directory_path ) )
{
    New-Item -Path "$shared_workspace_base_directory_path" -ItemType "directory" -ea 0
    powershell.exe -NoProfile -ExecutionPolicy Unrestricted -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Unrestricted -Command New-Item -Path $shared_workspace_directory_path -ItemType SymbolicLink -Value $git_root_path;pause' -Verb RunAs}";
}

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

# Replace mustache variables in local agent xml file
$filename = "$JENKINS_HOME\nodes\local\config.xml"
$tempFilePath = "$filename.tmp"

select-string -path $filename -pattern '(?<={{)(.*?)(?=}})' -allmatches  |
        foreach-object {$_.matches} |
        foreach-object {$_.groups[1].value} |
        Select-Object -Unique |
        ForEach-Object {
            try
            {
                Write-Output "Variable '$( (Get-Variable -Name "$( $_ )").Name )' has a value of $( (Get-Variable -Name "$( $_ )").Value )"
                (Get-Content -path $filename -Raw) -replace "{{$((Get-Variable -Name "$($_)").Name)}}","$((Get-Variable -Name "$($_)").Value)" | Set-Content -Path $tempFilePath
            } catch {
                Write-Output "Variable $_ could not be found. Check your jenkins.env file"
            }
            Move-Item -Path $tempFilePath -Destination $filename -Force
        }

# Check if in a Docker-Machine environment
if (Get-Command docker-machine.exe -ErrorAction SilentlyContinue)
{
    Write-Output "- [INFO] Running on a computer using Docker-Machine. Setting up the environment appropriately" | Blue
    docker-machine.exe -v
    $dockerMachineStatus = $( & docker-machine.exe status )
    if ( $dockerMachineStatus -ne "Running" ) {
        Write-Output "- [ERROR] Docker-Machine not running. Please start your Docker-Machine environment and try again" | Red
        Exit
    } else {
        Write-Output "- [INFO] Docker-Machine is running OK. Proceeding with Jenkins environment setup for KX.AS.CODE" | Blue
        $jenkinsUrl = "http://192.168.99.100:8080"
    }
} else {
    $jenkinsUrl = "http://127.0.0.1:8080"
}

# Check Docker type in order to ensure the correct mount-point
$dockerKernelVersion = $( & docker info --format '{{json .}}' | jq -r '.KernelVersion' )
$dockerOperatingSystem = $( & docker info --format '{{json .}}' | jq -r '.OperatingSystem' )

Write-Output $WORKING_DIRECTORY
Write-Output $JENKINS_HOME
Write-Output $dockerKernelVersion
Write-Output $dockerOperatingSystem
Write-Output $PSScriptRoot

if ( $dockerKernelVersion -like "*microsoft-standard-WSL2*" -And $dockerOperatingSystem -eq "Docker Desktop" ) {
  # Checking if jenkins_home and jenkins_remote are set correction to work with WSL2/Docker-Desktop
  Write-Output "- [INFO] Seems you are running on a Docker-Desktop/WSL2 combination. Checking Jenkins Docker volume setup" | Orange
  if ( $WORKING_DIRECTORY.StartsWith("/mnt" ) ) {
        Write-Output "Jenkins WORKING_DIRECTORY starts with /mnt. Seems to be compatible with Docker-Desktop/WSL2. Lets try..."
  } else {
        Write-Output "Jenkins WORKING_DIRECTORY does not start with /mnt which is not compatible with Docker-Desktop/WSL2. Will try to correct..." | Orange
        # Determine absolute work and shared_workspace directory paths
        $firstTwoChars = $WORKING_DIRECTORY.Substring(0,2)
        $secondChar = $WORKING_DIRECTORY.Substring(1,1)
        $firstChar = $WORKING_DIRECTORY.Substring(0,1)
        if ( $firstTwoChars -eq ".\" ) {
            $DOCKER_VOL_WORKDIR_ABSOLUTE_PATH = $WORKING_DIRECTORY.Substring(2)
            $DOCKER_VOL_WORKDIR_ABSOLUTE_PATH = "$PSScriptRoot\$DOCKER_VOL_WORKDIR_ABSOLUTE_PATH"
        }
        elseif ( $secondChar -eq ":" )
        {
            $DOCKER_VOL_WORKDIR_ABSOLUTE_PATH = $WORKING_DIRECTORY
        }
        else
        {
            $DOCKER_VOL_WORKDIR_ABSOLUTE_PATH = "$PSScriptRoot\$WORKING_DIRECTORY"

        }
        $DOCKER_VOL_WORKING_DIRECTORY = $DOCKER_VOL_WORKDIR_ABSOLUTE_PATH -replace "\\","/"
        $DOCKER_VOL_WORKING_DIRECTORY = $DOCKER_VOL_WORKING_DIRECTORY.substring(0,1).tolower() + $DOCKER_VOL_WORKING_DIRECTORY.substring(1)
        $DOCKER_VOL_WORKING_DIRECTORY = $DOCKER_VOL_WORKING_DIRECTORY -replace ":",""
        $DOCKER_VOL_WORKING_DIRECTORY = "/mnt/" + $DOCKER_VOL_WORKING_DIRECTORY
        Write-Output "DOCKER_VOL_WORKING_DIRECTORY: " + $DOCKER_VOL_WORKING_DIRECTORY
  }

  if ( $JENKINS_HOME.StartsWith("/mnt") ) {
        Write-Output "JENKINS_HOME starts with /mnt. Seems to be compatible with Docker-Desktop/WSL2. Lets try..."
  } else {
        Write-Output "JENKINS_HOME does not start with /mnt which is not compatible with Docker-Desktop/WSL2. Will try to correct..." | Orange
        # Determine absolute work and shared_workspace directory paths
        $firstTwoChars = $JENKINS_HOME.Substring(0,2)
        $secondChar = $JENKINS_HOME.Substring(1,1)
        $firstChar = $JENKINS_HOME.Substring(0,1)
        if ( $firstTwoChars -eq ".\" ) {
            $DOCKER_VOL_HOMEDIR_ABSOLUTE_PATH = $JENKINS_HOME.Substring(2)
            $DOCKER_VOL_HOMEDIR_ABSOLUTE_PATH = "$PSScriptRoot\$DOCKER_VOL_HOMEDIR_ABSOLUTE_PATH"
        }
        elseif ( $secondChar -eq ":" )
        {
            $DOCKER_VOL_HOMEDIR_ABSOLUTE_PATH = $JENKINS_HOME
        }
        else
        {
            $DOCKER_VOL_HOMEDIR_ABSOLUTE_PATH = "$PSScriptRoot\$JENKINS_HOME"

        }
        $DOCKER_VOL_JENKINS_HOME = $DOCKER_VOL_HOMEDIR_ABSOLUTE_PATH -replace "\\","/"
        $DOCKER_VOL_JENKINS_HOME = $DOCKER_VOL_JENKINS_HOME.substring(0,1).tolower() + $DOCKER_VOL_JENKINS_HOME.substring(1)
        $DOCKER_VOL_JENKINS_HOME = $DOCKER_VOL_JENKINS_HOME -replace ":",""
        $DOCKER_VOL_JENKINS_HOME = "/mnt/" + $DOCKER_VOL_JENKINS_HOME
        Write-Output "DOCKER_VOL_JENKINS_HOME: " + $DOCKER_VOL_JENKINS_HOME
  }
}

Remove-Item -Force -Path 'jenkins.env.docker-compose.ps1'
Foreach ($line in (Get-Content -Path "jenkins.env" | Where-Object {$_ -notmatch '^#.*'} | Where-Object {$_ -notmatch '^$'}))
{
    # Created for using with Docker-Compose
    if ( $line.StartsWith("jenkins_home") -Or $line.StartsWith("working_directory") ) {
        $lineArray=$line.split("=").Trim()
        if ( $line.StartsWith("jenkins_home") ) {
            $line = $lineArray[0] + "=`"$DOCKER_VOL_JENKINS_HOME`""
        } else {
            $line = $lineArray[0] + "=`"$DOCKER_VOL_WORKING_DIRECTORY`""
        }
    }
    $line -replace '^', '$env:' | Add-Content -Path 'jenkins.env.docker-compose.ps1'
}

# Check if Docker Jenkins container already exists
if ( $( & docker ps --filter=ancestor=$kx_jenkins_image -q ) ) {
    Write-Output "Jenkins already running. Restarting it in order to pick up changes" | Green
    $dockerJenkinsContainer = $( $( & docker ps --filter=ancestor=$kx_jenkins_image -q ) )
    docker restart $dockerJenkinsContainer
} elseif ( $( & docker ps -a --filter=ancestor=$kx_jenkins_image -q ) ) {
    Write-Output "Jenkins container exists but not running. Starting it up"
    $dockerJenkinsContainer = $( & docker ps -a --filter=ancestor=$kx_jenkins_image -q )
    docker start $dockerJenkinsContainer
} else {
    Write-Output "Jenkins not yet running and no container exists yet. Starting fresh with Docker-Compose.exe"
    . ./jenkins.env.docker-compose.ps1
    & ${dockerComposeBinary} --env-file ./jenkins.env.docker-compose.ps1 up -d
}

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
        Start-Sleep -Seconds 30
    }
}while($webRequest -ne "200")

Invoke-WebRequest -Uri $jenkinsUrl/jnlpJars/jenkins-cli.jar -OutFile .\jenkins-cli.jar
Invoke-WebRequest -Uri $jenkinsUrl/jnlpJars/agent.jar -OutFile .\agent.jar

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

# Start Jenkins agent
echo -e "- [INFO] Connecting the local agent to Jenkins..." | Blue
& $javaBinary -jar .\agent.jar -jnlpUrl $jenkinsUrl/computer/$agent_name/slave-agent.jnlp -workDir "$WORKING_DIRECTORY"
