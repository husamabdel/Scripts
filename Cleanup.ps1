###############################################
#
#            POWER CLEAN
#            @Author: Husam Abdalla
#            03/23/2022
#
###############################################

#This script is for organizing files in a directory.
#The script will create a directory for each File extension types.
#It will then ask for the option of creating a directory for directories or not.

#GLOBALS: A list for file extension types:

$TYPE = '.pdf', '.png', '.jpeg', '.jpg', '.docx', '.txt', '.xlsm', '.zip', '.mov', '.mp4', '.mp3', '.exe', '.ps1', '.bat', '.java'
$WC = '*'


function testForFile(){

    for($i = 0; $i -lt $TYPE.Count; $i++){

        ls $WC$TYPE[$i]
        
        if($?){

            Write-Host 'The file type '$TYPE[$i] ' Is not Found, Moving to next'
            continue

        }
        else{
        
            mkdir 'FILES:'$TYPE[$i]
            Move-Item -Path $WC$TYPE[$i] -Destination 'FILES:'$TYPE[$i]
            Write-Host 'Item Found, File Created and Items Moved'

        }

    }

    $REST = '.'
    ls $WC$REST
    if($? -eq $true){
    
        mkdir 'OTHER'
        Move-Item -Path '*.' -Destination 'OTHER'
    
    }
    else{
    
    Write-Host 'No other file types exist, continue: '

    }

    mkdir 'DIRECTORIES'
    Move-Item -Path * -Destination 'DIRECTORIES'


}

testForFile

if($?){
    Write-Host 'an unexpected error had occured, please try again or contact husamabdalla98@gmail.com to report bugs'
}
else{
    Write-Host 'Operation Completed Successfully!'
    exit 0
}
