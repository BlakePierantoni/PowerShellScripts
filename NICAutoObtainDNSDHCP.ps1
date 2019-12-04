###############################################################################################
#Script: Automaticly Obtain DNS/DHCP
#Date: 10/27/2019
#Author: Blake Pierantoni
#Description:
#This script set the NIC to automatically obtain DNS information from the DNS Server and then flush DNS
#PSVersion 4.0
#Reset DNS Settings to Automatically obtain from DNS/DHCP
##############################################################################################
Write-Host "Removing Static DNS/DHCP..."

#Set NIC to automatically obtain DNS and DHCP
$wmi = Get-WmiObject win32_networkadapterconfiguration -filter "ipenabled ='true'";
$wmi.EnableDHCP();
$wmi.SetDNSServerSearchOrder();

#Clear DNS Cache
Clear-DNSClientCache 
#Clear DNS Cache Windows 7
Ipconfig /flushdns
Write-Host "DNS Cache has been cleared. The Script is now complete"

#Net IP Configuration sent to console
Get-NetIPConfiguration -verbose