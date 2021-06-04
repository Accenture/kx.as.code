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

# Settings that will be used for provisioning Jenkins, including credentials etc
. ./jenkins.env.ps1

if ( $args.count -gt 1 ) {
    Write-Output "- [ERROR] You must provide one parameter only" | Red
    Exit
}

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

if ( $override_action -eq "recreate" -Or $override_action -eq "destroy" -Or $override_action -eq "fully-destroy" -Or $override_action -eq "uninstall" ) {
    $Input = Read-Host -Prompt "$areYouSureQuestion [Y/N]"
    Write-Output $Input
    if (  $Input -eq "Y" ) {
        Write-Output "- [INFO] OK! Proceeding to ${override_action} the KX.AS.CODE Jenkins environment"
        Write-Output "- [INFO] Deleting Jenkins jobs..." | Red
        Get-ChildItem ".\jenkins_home\jobs" -Recurse -Filter config.xml |
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
            docker rmi "$( docker images $KX_JENKINS_IMAGE -q )"
            Write-Output "- [INFO] Docker image deleted" | Red
            Write-Output "- [INFO] Deleting jenkins_home directory..." | Red
            Remove-Item -Recurse -Force -Path ./jenkins_home
            Write-Output "- [INFO] jenkins_home deleted" | Red
            if ($override_action -eq "fully-destroy")
            {
                Write-Output "- [INFO] Deleting jenkins_remote directory..." | Red
                Remove-Item -Path -Recursive -Force ./jenkins_remote
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

# Install Java
if (!(Get-Command java.exe -ErrorAction SilentlyContinue)) {
    Write-Output "Java not found. Downloading and installing to current directory under ./java" | Orange
    $webOutput = "amazon-corretto-windows-x64.zip"
    Invoke-WebRequest $javaInstallerUrl -OutFile .\$webOutput
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

# Replace mustache variables in job config.xml files
New-Item -Path ".\jenkins_home\jobs" -Name "logfiles" -ItemType "directory"
Copy-Item -Path ".\initial-setup\*" -Destination ".\jenkins_home\" -Recurse -Force
Get-ChildItem ".\jenkins_home\jobs" -Recurse -Filter config.xml |
Foreach-Object {
    Write-Output "Replacing parameters in job XML defintion file $(Write-Output $_.FullName)"
    $filename = $_.FullName
    $tempFilePath = "$filename.tmp"
    #$content = Get-Content $_.FullName
    #$pattern = "/{{(.*?)}}/"
    select-string -path $_.FullName -pattern '(?<={{)(.*?)(?=}})' -allmatches  |
            foreach-object {$_.matches} |
            foreach-object {$_.groups[1].value} |
            Select-Object -Unique |
            ForEach-Object {
                #Write-Output "Found string : $_"
                #Write-Output "Variable '$((Get-Variable -Name "$($_)").Name)' have a value of $((Get-Variable -Name "$($_)").Value)"
                (Get-Content -path $filename -Raw) -replace "{{$((Get-Variable -Name "$($_)").Name)}}","$((Get-Variable -Name "$($_)").Value)" | Set-Content -Path $tempFilePath
                Move-Item -Path $tempFilePath -Destination $filename -Force
                #Write-Output $tempFilePath

            }
            (Get-Content -path $filename -Raw) -replace "base-vm/build/jenkins/","base-vm\build\jenkins\" | Set-Content -Path $tempFilePath
            Move-Item -Path $tempFilePath -Destination $filename -Force

}

# Replace mustache variables in local agent xml file
$firstTwoChars = $WORKING_DIRECTORY.Substring(0,2)
Write-Output "firstTwoChars: $firstTwoChars"
$firstChar = $WORKING_DIRECTORY.Substring(0,1)
Write-Output "firstChar: $firstChar"
if ( $firstTwoChars -eq ".\" ) {
    Write-Output "One"
    $WORKDIR_ABSOLUTE_PATH = $WORKING_DIRECTORY.Substring(2)
    $WORKDIR_ABSOLUTE_PATH = "$PSScriptRoot\$WORKDIR_ABSOLUTE_PATH"
}
elseif ( $firstChar -ne "\" )
{
    Write-Output "Two"
    $WORKDIR_ABSOLUTE_PATH = "$PSScriptRoot\$WORKING_DIRECTORY"
}
else
{
    Write-Output "Three"
    $WORKDIR_ABSOLUTE_PATH = $WORKING_DIRECTORY
}
$WORKING_DIRECTORY = $WORKDIR_ABSOLUTE_PATH -replace "/","\"
Write-Output $WORKING_DIRECTORY

$filename = ".\jenkins_home\nodes\local\config.xml"
$tempFilePath = "$filename.tmp"

select-string -path $filename -pattern '(?<={{)(.*?)(?=}})' -allmatches  |
        foreach-object {$_.matches} |
        foreach-object {$_.groups[1].value} |
        Select-Object -Unique |
        ForEach-Object {
            Write-Output "Found string : $_"
            Write-Output "Variable '$((Get-Variable -Name "$($_)").Name)' have a value of $((Get-Variable -Name "$($_)").Value)"
            (Get-Content -path $filename -Raw) -replace "{{$((Get-Variable -Name "$($_)").Name)}}","$((Get-Variable -Name "$($_)").Value)" | Set-Content -Path $tempFilePath
            Move-Item -Path $tempFilePath -Destination $filename -Force
        }

# Check if in a Docker-Machine environment
if (Get-Command docker-machine.exe -ErrorAction SilentlyContinue)
{
    Write-Output "Running on a computer using Docker-Machine. Setting up the environment appropriately" | Blue
    docker-machine.exe -v
    $dockerMachineStatus = $( & docker-machine.exe status )
    if ( $dockerMachineStatus -ne "Running" ) {
        Write-Output "Docker-Machine not running. Please start your Docker-Machine environment and try again"
        Exit
    } else {
        Write-Output "Docker-Machine is running OK. Proceeding with Jenkins environment setup for KX.AS.CODE"
        $jenkinsUrl = "http://192.168.99.100:8080"
    }
} else {
    $jenkinsUrl = "http://127.0.0.1:8080"
}

# Check if Docker Jenkins container already exists
if ( $( & docker ps -a --filter=name=jenkins -q) ) {
    Write-Output "Jenkins already exists. Starting it up"
    docker start jenkins
} else {
    Write-Output "Jenkins not yet running. Starting with Docker-Compose.exe"
    & ${dockerComposeBinary} --env-file ./jenkins.env.ps1 up -d
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
Get-ChildItem ".\jenkins_home\" -Filter credential_*.xml |
        Foreach-Object {
            Write-Output "Replacing parameters in credential XML defintion file $(Write-Output $_.FullName)"
            $filename = $_.FullName
            select-string -path $_.FullName -pattern '(?<={{)(.*?)(?=}})' -allmatches  |
                    foreach-object {$_.matches} |
                    foreach-object {$_.groups[1].value} |
                    Select-Object -Unique |
                    ForEach-Object {
                        Write-Output "Found string : $_"
                        Write-Output "Variable '$((Get-Variable -Name "$($_)").Name)' have a value of $((Get-Variable -Name "$($_)").Value)"
                        (Get-Content -path $filename -Raw) -replace "{{$((Get-Variable -Name "$($_)").Name)}}","$((Get-Variable -Name "$($_)").Value)" | Set-Content -Path $tempFilePath
                        Move-Item -Path $tempFilePath -Destination $filename -Force
                    }
            Write-Output "& $javaBinary -jar .\jenkins-cli.jar -s $jenkinsUrl create-credentials-by-xml system::system::jenkins _"
            $content = Get-Content -Path $filename -Raw
            Write-Output $content | & $javaBinary -jar .\jenkins-cli.jar -s $jenkinsUrl create-credentials-by-xml system::system::jenkins _
        }

# Start Jenkins agent
& $javaBinary -jar .\agent.jar -jnlpUrl $jenkinsUrl/computer/$AGENT_NAME/slave-agent.jnlp -workDir "$WORKING_DIRECTORY"


