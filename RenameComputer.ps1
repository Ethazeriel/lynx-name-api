# Original Version: Michael Niehaus
# https://github.com/mtniehaus/RenameComputer

# Modified by Neil Merchant
# neil@lynxedge.com



Param()


# If we are running as a 32-bit process on an x64 system, re-launch as a 64-bit process
if ("$env:PROCESSOR_ARCHITEW6432" -ne "ARM64")
{
    if (Test-Path "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe")
    {
        & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy bypass -File "$PSCommandPath"
        Exit $lastexitcode
    }
}

# Create a tag file just so Intune knows this was installed
if (-not (Test-Path "$($env:ProgramData)\Lynxedge\RenameComputer"))
{
    Mkdir "$($env:ProgramData)\Lynxedge\RenameComputer"
}
Set-Content -Path "$($env:ProgramData)\Lynxedge\RenameComputer\RenameComputer.ps1.tag" -Value "Installed"

# Initialization
$dest = "$($env:ProgramData)\Lynxedge\RenameComputer"
if (-not (Test-Path $dest))
{
    mkdir $dest
}
Start-Transcript "$dest\RenameComputer.log" -Append

# Make sure we are already domain-joined
$goodToGo = $true
$details = Get-ComputerInfo
if (-not $details.CsPartOfDomain)
{
    Write-Host "Not part of a domain."
    $goodToGo = $false
}

# Make sure we have connectivity
$dcInfo = [ADSI]"LDAP://RootDSE"
if ($null -eq $dcInfo.dnsHostName)
{
    Write-Host "No connectivity to the domain."
    $goodToGo = $false
}

if ($goodToGo)
{
    # Get the new computer name
    $lynxInfo = Get-ComputerInfo | ConvertTo-Json -Depth 5;
    $lynxURI = "http://TEST-ADMIN01.corp.test.com:17346/name"
    $newName = Invoke-RestMethod -Method Post -Uri $lynxURI -Body $lynxInfo -Headers @{'content-type' = 'application/json'};

    # Set the computer name
    Write-Host "Renaming computer to $($newName)"
    Rename-Computer -NewName $newName

    # Remove the scheduled task
    Disable-ScheduledTask -TaskName "RenameComputer" -ErrorAction Ignore
    Unregister-ScheduledTask -TaskName "RenameComputer" -Confirm:$false -ErrorAction Ignore
    Write-Host "Scheduled task unregistered."

    # Return a 3010 exit code to soft reboot if we're in OOBE
    if ($details.CsUserName -match "defaultUser")
    {
        Write-Host "Exiting during ESP/OOBE with return code 3010"
        Stop-Transcript
        Exit 3010
    }
    else {
        Write-Host "Initiating a restart in 60 seconds"
        & shutdown.exe /g /t 60 /f /c "Rebooting in 60 seconds to ensure name change"
        Stop-Transcript
        Exit 0
    }
}
else
{
    # Check to see if already scheduled
    $existingTask = Get-ScheduledTask -TaskName "RenameComputer" -ErrorAction SilentlyContinue
    if ($null -eq $existingTask)
    {
        Write-Host "Scheduled task already exists."
        Stop-Transcript
        Exit 0
    }

    # Copy myself to a safe place if not already there
    if (-not (Test-Path "$dest\RenameComputer.ps1"))
    {
        Copy-Item $PSCommandPath "$dest\RenameComputer.PS1"
    }

    # Create the scheduled task action
    $action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-NoProfile -ExecutionPolicy bypass -WindowStyle Hidden -File $dest\RenameComputer.ps1"

    # Create the scheduled task trigger
    $timespan = New-Timespan -minutes 5
    $triggers = @()
    $triggers += New-ScheduledTaskTrigger -AtLogOn -RandomDelay $timespan
    $triggers += New-ScheduledTaskTrigger -AtStartup -RandomDelay $timespan
    
    # Register the scheduled task
    Register-ScheduledTask -User SYSTEM -Action $action -Trigger $triggers -TaskName "RenameComputer" -Description "RenameComputer" -Force
    Write-Host "Scheduled task created."
}

Stop-Transcript