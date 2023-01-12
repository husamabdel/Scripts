###################################################
#
#       Date Created: 8/11/2022
#
#
#
#       Heavy Hitters OSINT automation script
#
#       @Author: Husam Abdalla
#       Version: 1.00 
#       Using API void with API keys for Husam Abdalla.
#
#
#
#
#
#
#
#
#
####################################################
$dateObj = Get-Date
$Month = $dateObj.Month
$Day = $dateObj.Day
$year=$dateObj.Year


$Global:ips = [System.Collections.ArrayList]
$Global:apiIps = [System.Collections.ArrayList]
$Global:ips = $(Get-Content -Path "C:\Users\Husam.Abdalla\Documents\Heavy-Hitters\Heavy_Hitters.txt")
$Global:obj=New-Object -ComObject 'wscript.shell'
$Global:path = "C:\Users\Husam.Abdalla\Documents\Heavy-Hitters\Heavy_Hitters_${Month}_${Day}_${year}.txt"





#check the IP to see if a ticket is there!

function snowCheck($sip){


$bool = "0 results for ${sip}"
#Element 4 must contain 0




Start-Process https://N/A.servicenowservices.com/navpage.do

Sleep -Seconds 3

for($i=0;$i -lt 7; $i++){

    $obj.sendKeys("{TAB}")

}

$obj.SendKeys($sip)
$obj.SendKeys("{ENTER}")
#sleep 5

#$obj.SendKeys("{TAB}")

#$snArr=[System.Collections.ArrayList]

#$obj.SendKeys("^(a)")
#$obj.SendKeys("^(c)")

#$snArr=Get-Clipboard

#echo $snArr



foreach($index in $snArr){

    if($index -eq $bool){
    
        echo "You can proceed, ${sip} was not found in Service Now."
        return $false
        break

    } else{continue}
    echo 'Its found in service now'
    exit 1   

}







}




    $index=0
    foreach($ip in $ips){

     snowCheck($ip)
     
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
        ***********************
        ${ip} ${country}

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
     
        Write-Output $tempObject >> $path

        $apiIps[$index]=$tempObject

    
    }

    $obj.Popup("TASK COMPLETED SUCCESSFULLY",2+16,"ALERT")

