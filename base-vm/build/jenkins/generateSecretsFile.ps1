$scriptParam = ($MyInvocation.Line -replace ('^.*' + [regex]::Escape($MyInvocation.InvocationName)) -split '[;|]')[0].Trim()
$Log_Level = "info"

# Executable paths if required

$opensslVersionRequired = "1.1.1"

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

function Log_Info
{
    param ([string]$Message)

    if ($Log_Level -eq "info" -Or $Log_Level -eq  "error" -Or $Log_Level -eq "warn" -Or $Log_Level -eq "debug")
    {
        Write-Host "[INFO] $Message"
    }
}

function Log_Debug
{
    param ([string]$Message)

    if ($Log_Level -eq "debug")
    {
        Write-Host "[DEBUG] $Message"
    }
}

function Log_Warn
{
    param ([string]$Message)

    if ( $Log_Level -eq  "error" -Or $Log_Level -eq "warn" -Or $Log_Level -eq "debug" -Or $Log_Level -eq "info")
    {
        Write-Host "[WARN] $Message" -ForegroundColor DarkYellow
    }
}

function Log_Error
{
    param ([string]$Message)

    if ( $Log_Level -eq "error" -Or $Log_Level -eq "debug" )
    {
        Write-Host "[ERROR] $Message" -ForegroundColor Red
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

function checkVersions
{

    param ([string]$scriptParam)

    #checkOpenSslVersion

    Log_Debug "Errors: ${checkErrors}"
    Log_Debug "Warnings: ${checkWarnings}"

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
        }
        -r {
            $override_action = "recreate"
        }
        -f {
            $override_action = "fully-recreate"
        }
        -h {
            Write-Output "The .\generateSecretsFile.ps1 script has the following options:
              -i  [i]gnore warnings and start the secret filw generator anyway, knowing that this may cause issues
              -f  [f]ully recreate hash and secrets file
              -r  [r]ecreate secrets file using existing hash
              -h  [h]elp me and show this help text`n"
            Exit
        }
        default {
            Log_Error "Invalid option: $($scriptParam). Call .\generateSecretsFile.ps1 -h to display help text`n"
            .\generateSecretsFile.ps1 -h
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

if ( $override_action -eq "recreate" -Or $override_action -eq "fully-recreate" ) {
    Log_Info "OK! Proceeding to ${override_action} the secrets file"
    if (test-path .\securedCredentials_backup)
    {
        Log_Info "Removing existing backup file - .\securedCredentials_backup"
        Remove-Item -Force -Path .\securedCredentials_backup
    }
    Log_Info "Renaming exising secrets file to .\securedCredentials_backup"
    Rename-Item -Force -Path .\securedCredentials  -NewName .\securedCredentials_backup
    if ($override_action -eq "fully-recreate")
    {
        if (test-path .\credentials_salt_backup)
        {
            Log_Info "Removing existing backup file - .\credentials_salt_backup"
            Remove-Item -Force -Path .\credentials_salt_backup
        }
        Log_Info "Renaming exising secrets file to .\credentials_salt_backup"
        Rename-Item -Force -Path .\credentials_salt  -NewName .\credentials_salt_backup
    }
}
else
{
    Log_Info "You launched generateSecretsFile.ps1 without any options. Exiting."
    .\generateSecretsFile.ps1 -h
    Exit
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
    $env:Path += ";$openssl_path"
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
    $path_to_git_executable = "$PSScriptRoot\Git\bin\git.exe"
    $path_to_sh_executable = "$PSScriptRoot\Git\bin\sh.exe"
    $path_to_openssl_executable = "$PSScriptRoot\Git\usr\bin\openssl.exe"
}
else
{
    # Checking Windows specific pre-requisites
    # Git bash must be installed and available, else "sh" will not work in the Jenkins pipeline
    if ((Get-Command "C:\Program Files\Git\bin\git.exe" -ErrorAction SilentlyContinue) -And (Get-Command "C:\Program Files\Git\bin\sh.exe" -ErrorAction SilentlyContinue))
    {
        $path_to_git_executable = "C:\Program Files\Git\bin\git.exe"
        $path_to_sh_executable = "C:\Program Files\Git\bin\sh.exe"
        $path_to_openssl_executable = "C:\Program Files\Git\usr\bin\openssl.exe"
        $env:Path = ";C:\Program Files\Git\bin\;C:\Program Files\Git\usr\bin\;" + $env:Path
    }
    elseif ( (Get-Command "$Env:HOMEDRIVE\$Env:HOMEPATH\AppData\Local\Programs\Git\bin\git.exe"  -ErrorAction SilentlyContinue) -And (Get-Command "$Env:HOMEDRIVE\$Env:HOMEPATH\AppData\Local\Programs\Git\bin\sh.exe"  -ErrorAction SilentlyContinue) )
    {
        $path_to_git_executable = "$Env:HOMEDRIVE\$Env:HOMEPATH\AppData\Local\Programs\Git\bin\git.exe"
        $path_to_sh_executable = "$Env:HOMEDRIVE\$Env:HOMEPATH\AppData\Local\Programs\Git\bin\sh.exe"
        $path_to_openssl_executable = "$Env:HOMEDRIVE\$Env:HOMEPATH\AppData\Local\Programs\Git\usr\bin\openssl.exe"
        $env:Path = "$Env:HOMEDRIVE\$Env:HOMEPATH\AppData\Local\Programs\Git\bin;$Env:HOMEDRIVE\$Env:HOMEPATH\AppData\Local\Programs\Git\usr\bin;" + $env:Path
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
    }
    elseif ( (Get-Command "$Env:HOMEDRIVE\$Env:HOMEPATH\AppData\Local\Programs\Git\usr\bin\nohup.exe" -ErrorAction SilentlyContinue) -And ( Test-Path -Path "$Env:HOMEDRIVE\$Env:HOMEPATH\AppData\Local\Programs\Git\usr\bin\msys-2.0.dll") -And ( Test-Path -Path "$Env:HOMEDRIVE\$Env:HOMEPATH\AppData\Local\Programs\Git\usr\bin\msys-iconv-2.dll") )
    {
        $path_to_nohup_executables = "$Env:HOMEDRIVE\$Env:HOMEPATH\AppData\Local\Programs\Git\usr\bin"
        $env:Path = "$Env:HOMEDRIVE\$Env:HOMEPATH\AppData\Local\Programs\Git\usr\bin;" + $env:Path
        $downloadAndInstallPortableGit = "true"
        $softLinkTarget = "$Env:HOMEDRIVE\$Env:HOMEPATH\AppData\Local\Programs\Git\usr\bin"
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

checkOpenSslVersion

if (!(test-path .\credentials_salt))
{
    # Create salt for encryption
    $credentials_salt = & $path_to_openssl_executable rand -base64 12
    Write-Output $credentials_salt | Out-File -FilePath .\credentials_salt
    Log_Info "Done. Created credentials_salt file"
}
else
{
    Log_Info "Using existing credentials_salt file"
    $credentials_salt = Get-Content -Path .\credentials_salt -TotalCount 1
    Log_Debug "credentials_salt: $credentials_salt"
}

if (!(test-path .\securedCredentials))
{
    # Create encrypted secrets file for importing into VM
    $credentialsToStore = "git_source_username git_source_password dockerhub_username dockerhub_password dockerhub_email"
    $credentialsToStore.Split(" ") | ForEach {
        $encryptedCredential = (Write-Output $( Get-Variable "$_" -ValueOnly ) | & $path_to_openssl_executable enc -aes-256-cbc -pbkdf2 -salt -A -a -pass pass:$credentials_salt)
        # Test Unencryption
        $unencryptedCredential = (Write-Output $encryptedCredential | & $path_to_openssl_executable enc -aes-256-cbc -pbkdf2 -salt -A -a -pass pass:$credentials_salt -d)
        if ( $unencryptedCredential -ne $( Get-Variable "$_" -ValueOnly ) ) {
            Log_Error "Encryption and subsequent decryption value do not match."
        }
        "$_`:$encryptedCredential" | Out-File -FilePath .\securedCredentials -Append
    }
    Log_Info "Done. Created encrypted secrets file"
} else {
    Log_Info "Found existing .\securedCredentials, skipping."
}
