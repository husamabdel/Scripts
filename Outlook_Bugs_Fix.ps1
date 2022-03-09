################################
#
#       Outlook bugs fix
#       @Author: Husam Abdalla
#       3/2/22
#
################################

$USER = $env:UserName
$PCID = $(hostname)
$SERVER = '140.147.32.139'
$PROCESS_TERMINATE = 'Outlook.exe', 'ZoomOutlookIMPlugin.exe', 'lync.exe', 'UcMapi.exe', 'atmgr.exe', 'CiscoWebexStart.exe'

#Check version installed:

if(Test-Path 'C:\Program Files (x86)\Microsoft Office\Office16'){

    echo 'Outlook Installed, continue: '

}

#Issue is mainly with Outlook 2016, may not work with other versions.

else{

    echo 'Another version of Office installed, this script might not work...'

}

#Function to check the network first, will exit if the issue is a network issue.
function CheckNet(){

    Test-Connection $SERVER
    if(!$?){
    
        echo 'Error! device cannot connect to exchange because it is not connected to the internet! please reconnect to your network and try again!'
        echo 'Exit code: ' $?
        exit 1
    }

}

#Main Fumnction to kill all tasks.

function KillTasks(){

    echo 'WARNING, THE FOLLOWING PROCESSES WILL BE SHUT DOWN: ' ${PROCESS_TERMINATE} ' TERMINATE TO STOP!'
    timeout 3

  for($i = 0; $i -lt $PROCESS_TERMINATE.Count; $i++){
  
    Taskkill /IM $PROCESS_TERMINATE[$i] /F
    
    if(!$?){
        echo 'Process is not online'
    }

  }


}


function testStartup(){

    $selection = 'Sent To OneNote.lnk', 'Zoom.lnk', 'Skype.lnk', 'Outlook.lnk'

    if(Test-Path "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"){
    
        
        for($i = 0; $i -lt $selection.Count; $i++){
        
            $FLAG = $(ls "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup" | Select-String $selection[$i])
            if($FLAG -eq $null){
            
                Write-Host 'Doesnt cause errors, continue'

            }

            else{
            
                Remove-Item -Path "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\$selection[$i]"

            }


        }

    
    }

    else{
    
        Write-Host 'Startups not enabled? '
        exit 1

    }

}

#Calling in Net Check

CheckNet

#Calling in killTasks and flushing the dns, as well as starting outlook again.

KillTasks

#Remove problematic startups:

testStartup

#Lastly: 

ipconfig /flushdns
start Outlook.exe
echo 'Exit code: ' $?
echo 'Process Completed for user: ' $USER ' on: ' $PCID
