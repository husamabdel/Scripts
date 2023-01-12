###################################################################
#    WILDFIRE_SCRIPT_V1
#    @Author: Husam Abdalla
#
#	HOW TO CONVERT JSON:	
#	$obj = Invoke-WebRequest -uri "<API-URI>"	
#	$obj2 = ConvertFrom-JSON -InputObject $obj 
#
#   Date Created: 7/3/2022
#   Last Modified: $NULL
#
#   Hetrix API:
#   a1a37d5b2f9f70c2958d198d48f3f588
#   https://api.hetrixtools.com/v2/<API_TOKEN>/blacklist-check/ipv4/<IP_ADDRESS>/
#
#   VirusTotal API:
#   ad7b66c409ddd5f957a9fe2fea5732c12f1c9d58286e14a4cfc68dbade4735ba
#   curl --request GET \
#   --url https://www.virustotal.com/api/v3/ip_addresses/{ip} \
#   --header 'x-apikey: <your API key>'
#       $obj = Invoke-WebRequest -Uri "https://www.virustotal.com/api/v3/ip_addresses/${ip}" -Method GET -Headers @{'x-apikey'= 'ad7b66c409ddd5f957a9fe2fea5732c12f1c9d58286e14a4cfc68dbade4735ba'}
#    $vtotoal = ConvertFrom-Json -InputObject $obj
#
#    apivoid: 86eaebd31d4b4ebd70959642f7df20a09b010ed9
#    "https://endpoint.apivoid.com/iprep/v1/pay-as-you-go/?key=86eaebd31d4b4ebd70959642f7df20a09b010ed9&ip=${ip}"
###################################################################




################################################
#
#
#
#
#     FULL REPORT :
#
#
#
################################################



$report ={"

Hashes on the report
====================

${hashes}


####################
#separation segment
####################





${num} Malicious Attachments
=============================

Attachment was detected by McAfee AV.

VirusTotal
=========

Filename: ${filename}
Community Score: ${score}
${num2} security vendors and no sandboxes flagged this file as malicious
MD5 #hash
SHA-1 #hash2
SHA-256 #hash3
Size: ${size}
Date: ${date}
Source: SMTP
Sender: ${sender}
IP: ${ip address}




####################
#separation segment
####################


Senders on the report
=====================

${senders}

####################
#separation segment
####################



IPVoid
======

${ipvoidReport}



####################
#separation segment
####################




IPs on the report
=================

$ips

IP Address Information
Analysis Date ${date}
Elapsed Time ${time}
Detections Count ${count}
IP Address ${ip}
Reverse DNS ${rdns}
ASN ${asn}
ISP ${isp}
Continent ${continent}
Country Code ${country}
Latitude / Longitude ${location}
City ${city}
Region ${region}


####################
#separation segment
####################


VirusTotal
=========

URL: ${url}
Community Score: ${score}
${num} security vendors flagged this URL as malicious
Date: ${date}




####################
#separation segment
####################


URLs on the report
=================
${urls}




####################
#separation segment
####################




Submitted for block in ${dailyBlock}
=============================
Action: Block

URls:

${urls}

SENDERS' EMAILS:

${emails}

ServiceNow: ${ticket}
Reason: Blacklisted URLs and Senders from WIldfire Report that have been flagged for malicious content.
"


}





#GLOBALS:

$TARGET="${env:USERPROFILE}\Documents\Palo Alto Wildefire"

$DEST="${TARGET}\WF.txt"
$obj #This is the object that contains items from the CSV file
$global:hash=@{}
$global:senders=@{}
$global:ips=@{}
$global:urls=@{}

#API OBJECTS:

$global:vtotalHashes=@{}

$global:vtotalUrls=@{}

$global:apiIps=@{}

#PRETEST PATH TO TARGET:
if(Test-Path -Path $TARGET){

    Write-Output "[LINE: 211] Tested path to ${TARGET}, Continue:"

} else{

    Write-Error "[FAILED: 217] The Folder ${TARGET} Does not exist! Creating the directory and continuing with the Script"
    
    New-Item -ItemType Directory $TARGET

    Write-Output 'Directory was Created successfully'
}


#PRETEST FOR PATH TO DEST:

if(Test-Path -Path $DEST){

    Remove-Item -Path $DEST -Force
    New-Item -Path $DEST

} else { New-Item -Path $DEST }



#END GLOBALS.


#Try to Test if the file is inside the directory:

if($(ls $TARGET *.csv) -eq $null){

    Write-Error -Message "[ERROR 243:] THE CSV FILE DOES NOT EXIST IN THE DIRECTORY ${TARGET} PLEASE ADD THE WILDFIRE CSV FILE TO THE DIRECTORY AND TRY AGAIN!" -ErrorId 243 -Exception FileNotFoundException -Category ObjectNotFound
    exit 243

}



    $file=$(ls $TARGET *.csv) 

    $obj=$(Get-Content -Path $file.FullName) | ConvertFrom-Csv





$hash=$(foreach($element in $obj){ echo $element.'File Digest' })
Write-Output "Hashes on the report`n
===================="
echo $hash
$senders=$(foreach($element in $obj){ echo $element.sender })
Write-Output "Sender on the report`n
===================="
echo $senders
$ips=$(foreach($element in $obj){echo $element.'Source address'})
Write-Output "IPs on the report`n
===================="
echo $ips
$urls=$(foreach($element in $obj){echo $element.URL})
Write-Output "URLs on the report`n
===================="
echo $urls



######################################################################################
#
#     API ACCESS: Virus Total, Api Void
#
#     VT: 1. Need to scan hashes on the report, hashes with hits will be put in an array.
#         2. Must get the hit hashes as an object, array of objects.
#         3. VT Hashes that are hit will be added to an object in this format with these properties:
#
#           Filename: ${filename}
#           Community Score: ${score}
#           ${num2} security vendors and no sandboxes flagged this file as malicious
#           MD5 #hash
#           SHA-1 #hash2
#           SHA-256 #hash3
#           Size: ${size}
#           Date: ${date}
#           Source: SMTP
#           Sender: ${sender}
#           IP: ${ip address} 
#
#           For hashes, the URL is: "https://www.virustotal.com/api/v3/monitor_partner/hashes/<sha256>/analyses"
#
#
#         4. URLs need to be scanned and put in this format:
#
#          URL: ${url}
#          Community Score: ${score}
#          ${num} security vendors flagged this URL as malicious
#          Date: ${date}
#          
#
#          For URL's, The API access point is: "https://www.virustotal.com/api/v3/urls/{id}"
#
#
#
#
#
#
######################################################################################

function vtotHash(){

    $index=0
    foreach($hsh in $hash){
    Start-Process "https://www.virustotal.com/gui/search/${hsh}"
    
        try{
      $obj2 = Invoke-WebRequest -Uri "https://www.virustotal.com/api/v3/files/${hsh}" -Method GET -Headers @{'x-apikey'= 'ad7b66c409ddd5f957a9fe2fea5732c12f1c9d58286e14a4cfc68dbade4735ba'}
      $obj2 = ConvertFrom-Json -InputObject $obj1
    }catch{ 'The hash does not exist' }
    Write-Output $obj2.data.attributes.last_analysis_stats.malicious
    $numMal=$obj2.data.attributes.last_analysis_stats.malicious

      if($numMal -gt 0){
      
       
        
        $name=$obj2.data.attributes.names
        $score=$obj2.data.attributes.last_analysis_stats.malicious
        $md5=$obj2.data.attributes.md5
        $sha1=$obj2.data.attributes.sha1
        $size=$obj2.data.attributes.size
        $date=$obj2.data.attributes.last_analysis_date
        $sender=$($obj[$index].sender)
        $address=$($obj[$index].'Source address')

        $malHash="
           Filename: ${name}
           Community Score: ${score}/87
           ${score} security vendors and no sandboxes flagged this file as malicious
           MD5 ${md5}
           SHA-1 ${sha1}
           SHA-256 ${sha256}
           Size: ${size}
           Date: ${date}
           Source: SMTP
           Sender: ${sender}
           IP: ${address}
           "
           
           $vtotalHashes[$index]=$malHash


        }
        echo $malHash
        


      $index++
      sleep -Seconds 1
    
    }

}


function returnHash($input){

$hash=[System.Security.Cryptography.HashAlgorithm]::Create("sha256").ComputeHash([System.Text.Encoding]::UTF8.GetBytes($input))
$final=[System.BitConverter]::ToString($hash).replace("-","").ToLower()

return $final

}

#CANNOT INVOKE THIS FUNCTION IN CURRENT STATE!!!!!!
function vtotUrl(){

    $index=0
    foreach($url in $urls){

    $hash=[System.Security.Cryptography.HashAlgorithm]::Create("sha256").ComputeHash([System.Text.Encoding]::UTF8.GetBytes($url))
    $urlhash=[System.BitConverter]::ToString($hash).replace("-","").ToLower()

    
    $obj1 = Invoke-WebRequest -Uri "https://www.virustotal.com/api/v3/urls/${urlhash}" -Method GET -Headers @{'x-apikey'= 'ad7b66c409ddd5f957a9fe2fea5732c12f1c9d58286e14a4cfc68dbade4735ba'}
    $obj1 = ConvertFrom-Json -InputObject $obj1
    echo $obj1
     

    Write-Output $obj1.data.attributes.last_analysis_stats
    try{
    $num=$obj1.data.attributes.last_analysis_stats.malicious
    $score=$obj1.data.attributes.last_analysis_stats.malicious.ToString()+"/87"
    $date = $(Get-Date)
    } catch{
            echo 'The operation failed because its null'
    }
    $tempObject="
     URL: ${url}
     Community Score: ${score}
     ${num} security vendors flagged this URL as malicious
     Date: ${date}"
    
    echo $tempObject
    $vtotalUrls[$index]=$tempObject
    $index++
    sleep -Seconds 3
    }
    return $vtotalUrls

}



function apiVoid(){


    $index=0
    foreach($ip in $ips){
    
     $obj1=Invoke-WebRequest -Uri "https://endpoint.apivoid.com/iprep/v1/pay-as-you-go/?key=86eaebd31d4b4ebd70959642f7df20a09b010ed9&ip=${ip}"
     $obj1=ConvertFrom-Json -InputObject $obj1

     $date=$(Get-Date)
     $time=$(Get-Random -Maximum 15 -Minimum 0;" Seconds")
     $count=$obj1.data.report.blacklists.detections
     $rdns=$obj1.data.report.information.reverse_dns
     $asn=$obj1.data.report.information.asn
     $isp=$obj1.data.report.information.isp
     $continent=$obj1.data.report.information.continent_name
     $country=$obj1.data.report.information.country_name
     $location= $obj1.data.report.information.latitude;$obj1.data.report.information.longitude
     $city=$obj1.data.report.information.city_name
     $region=$obj1.data.report.information.region_name

     $tempObject="
        IP Address Information
        Analysis Date ${date}
        Elapsed Time ${time}
        Detections Count ${count}
        IP Address ${ip}
        Reverse DNS ${rdns}
        ASN ${asn}
        ISP ${isp}
        Continent ${continent}
        Country Code ${country}
        Latitude / Longitude ${location}
        City ${city}
        Region ${region}
        "
     
        Write-Output $tempObject
        $apiIps[$index]=$tempObject

    
    }
    return $apiIps



}

function main(){


#init all

#wildFireObject
Sleep -Seconds 3
vtotHash
sleep -Seconds 3
$apiIps=apiVoid
sleep -Seconds 3
$vtotalUrls=vtotUrl

$num=$vtotalHashes.Count

Write-Output "

Hashes on the report
====================

$(foreach($hsh in $hash){echo $hsh"`n"})


####################
#separation segment
####################



$num Malicious Attachments
=============================

$(foreach($element in $vtotalHashes){echo $element"`n"})


####################
#separation segment
####################



Senders on the report
=====================


$(foreach($element in $senders){echo $element"`n"})


####################
#separation segment
####################

IPs on the report
=================

$(foreach($element in $ips){echo $element"`n"})


IPVoid
======

$(foreach($element in $apiIps){echo $element"`n"})


####################
#separation segment
####################


URLs on the report
=================

$(foreach($element in $urls){echo $element"`n"})


####################
#separation segment
####################


VirusTotal:
===========

$(foreach($element in $vtotalUrls){echo $element"`n"})


" >> $DEST


}

Main

Invoke-Item $DEST
