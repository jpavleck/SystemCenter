<#
    SCOM Notification Command Channel Test

    How to use this script:
    1. Change the log location variable to a place that exists on all management servers
        1a. Either change $scriptLocation to the path you placed this script, or pass it to the script
    2. Copy this script to all management servers
        A one-liner: After making the same directory structure on each MS, you can do this to copy scripts over:
            Get-SCOMManagementServer |% { Copy-Item -Path $scriptLocation -Destination "\\$($_.NetworkName)\c$\Path\To\Folder" -Force}
    3. When creating the command, use these settings:
        Path: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
        Command: -executionPolicy Bypass -noprofile -file "X:\Path\to\SCOMCommandTest.ps1" '  # Quotes matter.
        Startup: X:\Path\To\SCOMCommandTest.ps1

    Author:

                                                 _  _
                                               || \|_)
                                             \_||_/|

#>

####### USER DEFINED VARIABLED - CHANGE THIS ######
$logLocation = "C:\Windows\Temp"
$ScriptLocation = "C:\SCOM\Scripts\Test"
$logName = "SCOM-Notification-Command-Test-transcript.log"
###################################################
# Script variables - do not edit
#
# First things first, create a file to show that the script was at least started and began 

$logFullPath = Join-Path -Path $logLocation -ChildPath $logName
$whoami = whoami
$ScriptName = $MyInvocation.MyCommand
$sevInfo = 0
$sevErr = 1
$sevWarn = 2
$EventID = 926
If($(Test-Path -Path $logFullPath){
    Write-Output "The file $logFullPath already exists. Adding '.bak' to it. "
    Move-Item -Path $logFullPath -Destination "$($logFullPath).bak"
}
Start-Transcript -Path $(Join-Path -Path $logLocation -ChildPath $logName) -IncludeInvocationHeader
$scomAPI = New-Object -ComObject mom.ScriptAPI
$scomAPI.LogScriptEvent($ScriptName, $EventID, $sevInfo, "This event is logged to verify end-to-end functionality of the SCOM Command Notification Channel `nRunning as: ($whoami) ")
If($profile){
    Write-Output "Profile: Using the following PowerShell profile: $($profile)"}
    else {
        Write-Output "Profile: Not using a profile"
    }
}
Write-Output  "Script: $PSCommandPath"
Write-Output  "Present Working Directory: $PWD"
If($args) {
    Write-Output "There are $($args.Count) arguments"
    $i = 0
    foreach ($item in $args) {
        Write-Output "`tArgument at position $i is $item"
        $i++
    }
}
Write-Output "Invocation Name: $($MyInvocation.InvocationName)"
Write-Output $MyInvocation.ScriptName
Write-Output $MyInvocation.UnboundArguments
Write-Output "Command Path: $($MyInvocation.PSCommandPath)"
Write-Output "Script Path: $($MyInvocation.PSScriptRoot)"
$PSBoundParameters
$PSScriptRoot
$PSCommandPath
$PID
$PSSenderInfo
$PWD


$MyInvocation
"*********************************"
$HOST
"**********************************"
$Profile

If($useSCOM) {
    $Error.Clear()
    # Import the OperationsManager module and connect to the management group
    $SCOMPowerShellKey = "HKLM:\SOFTWARE\Microsoft\System Center Operations Manager\12\Setup\Powershell\V2"
    $SCOMModulePath = Join-Path (Get-ItemProperty $SCOMPowerShellKey).InstallDirectory "OperationsManager"
    Import-module $SCOMModulePath
    TRY {
        New-DefaultManagementGroupConnection -managementServerName "localhost"
    }
    CATCH {
        IF ($Error) {
            $momapi.LogScriptEvent($ScriptName, $EventID, 1, "`n FATAL ERROR: Unable to load OperationsManager module or unable to connect to Management Server. `n Terminating script. `n Error is: ($Error).")
            EXIT
        }
    }

    $notiPool = Get-SCOMResourcePool -DisplayName "Notifications Resource Pool"
    If($notiPool.members.count -gt 1) {
        Write-Output "Notifications Resource Pool has ($notiPool.members.count) members: `n$($notipool.members | select-object -Property DisplayName)"
        Write-Output "Verifying that script '$($PSCommandPath)' exists on all members:"
        $remotePath = $PSCommandPath.Replace(":","$")
        foreach($member in $notiPool.members) {
            If($(Test-Path "\\$member\$remotePath")){
                Write-Output "`t**PASS** Member $member has a local copy of $ScriptName at $PSCommandPath"
                $evntlogOut = $evntlogOut + "$member has local copy of $PSCommandPath`n"
            } else {
                Write-Output "`t**FAIL** Member $member does NOT have a local copy of $ScriptName at $PSCommandPath"
                $evntlogOut = $evntlogOut + "!!ERROR!! $member test for file  $PSCommandPath failed - File Not Found"
            }
            $momAPI.LogScriptEvent($ScriptName, 927, 0, $evntlogOut)
        }
        $CommandChannels = Get-SCOMNotificationChannel | Where-Object {$_.ChannelType -eq "Command"}
        Write-Output "Found $CommandCHannels.Count notification channels that call a command"
        foreach($command in $CommandChannels) {
            "Command Display Name: $command.DisplayName`n `tCommand Action: $command.action`n`n"
        }
    }
}
