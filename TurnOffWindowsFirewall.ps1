####################################################################
#Script: Turn Off Windows Firewall
#Date: 10/29/2019
#Author: Blake Pierantoni
#Description: Turn off Windows Domain, Public, and Private Firewall
####################################################################
Write-Host "Turning Off Windows Firewall: Domain, Public, Private"
Set-NetFirewallProfile -Profile domain,public,private -Enabled false