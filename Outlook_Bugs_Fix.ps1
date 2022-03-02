################################
#
#       Outlook bugs fix
#       @Author: Husam Abdalla
#       3/2/22
#
################################

$USER = $env:UserName
$PCID = $(hostname)
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

    Test-Connection 9.9.9.9
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

#Calling in Net Check

CheckNet

#Calling in killTasks and flushing the dns, as well as starting outlook again.
KillTasks

ipconfig /flushdns
start Outlook.exe
echo 'Exit code: ' $?
echo 'Process Completed for user: ' $USER ' on: ' $PCID
