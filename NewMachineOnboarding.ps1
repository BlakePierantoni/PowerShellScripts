##############################################################################################################################################################################################
###############################################################################################
###############################################################################################
###############################################################################################
#Script: MTP Onboarding Script
#Date: 10/25/2019
#Author: Blake Pierantoni
#Description: The Script Enables RDP, Turns off Windows Firewall, Sets Power Configuration to "High Performance", Creates MTP Service Accounts.
###############################################################################################
###############################################################################################
###############################################################################################
##############################################################################################################################################################################################
#Turn Off Windows Firewall
#



Set-NetFirewallProfile -Profile domain,public,private -Enabled False
    Write-Host "Turning of Windows Firewall for Domain, Public, and Private"


###############################################################################################
###############################################################################################
###############################################################################################
#PowerCFG 
#


#Set machine to high performance power settings
Powercfg /SETACTIVE SCHEME_MIN
#Turn off hibernate option
    Powercfg /Hibernate off
#Turn monitor off after 60 minutes (Not sleep)
    Powercfg /Change monitor-timeout-ac 60
    Powercfg /Change monitor-timeout-dc 60
#Turn off sleep 
    Powercfg /Change standby-timeout-ac 0
    Powercfg /Change standby-timeout-dc 0
#Set disk to never turn off
    Powercfg /Change disk-timeout-ac 0
    Powercfg /Change disk-timeout-dc 0

    Write-Host "Turned on High Performance Power Settings, Monitor Off after 60 Minutes, No Sleep, Disk never turns off"



###############################################################################################
###############################################################################################
###############################################################################################
#Adjust NIC Powersettings
Write-host "Disabling Power savings settings for Physical NICs (Will not allow windows to turn off device)"
foreach ($NIC in (Get-NetAdapter -Physical)){
    $PowerSaving = Get-CimInstance -ClassName MSPower_DeviceEnable -Namespace root\wmi | ? {$_.InstanceName -match [Regex]::Escape($NIC.PnPDeviceID)}
    if ($PowerSaving.Enable){
        $PowerSaving.Enable = $false
        $PowerSaving | Set-CimInstance
    }
}

###############################################################################################
###############################################################################################
###############################################################################################
#Enable RDP
#Enable Remote Desktop Connections
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\' -Name "fDenyTSConnections" -Value 0
    Write-host "Enabling Remote Desktop"
#Enable Network Level Authentication
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\' -Name "UserAuthentication" -Value 1
    Write-host "Enabling Network Level Authentication"
#Enable Windows Firewall Rules to Allow RDP
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
    Write-host "Creating RDP Firewall Rules"

###############################################################################################
###############################################################################################
###############################################################################################
#Add Service Accounts
#Defining the ErrorActionPreference


Write-Host "Adding MTP Local Service Accounts"
$ErrorActionPreference = 'Stop'

#Defining the Password input from AEM and Converting it to a secure string
#The input from AEM is equal to the variable $Env:Password
#PowerShell requires secure strings to be used as passwords

#Converting the Password for Software account to a secure string 
$PlainPassword = #Enter Password for Account 1 in here

$SecurePassword = $PlainPassword | ConvertTo-SecureString -AsPlainText -Force

#Converting Password for MyTechPro Account as secure string
$PlainPassword2 = #Enter Password for Account 2 in here

$SecurePassword2 = $PlainPassword2 | ConvertTo-SecureString -AsPlainText -Force

#User to search for
$USERNAME = "Software" #Change name to reflect the name of your first admin account
$USERNAME2 = "MyTechPro" #Change name to reflect the name of your second admin account
#Declare LocalUser Object
$ObjLocalUser = $null
$ObjLocalUser2 = $null

#Using Try to search for $USERNAME
Try {
    Write-Host "Searching for $("$USERNAME and $USERNAME2") in Local Users"
    $ObjLocalUser = Get-LocalUser $USERNAME
    Write-Host "User $($USERNAME) was found"

    $ObjLocalUser2 = Get-LocalUser $USERNAME2
    Write-Host "User $($USERNAME2) was found"
}



#Catching the account doesnt exist error and reports back to console
Catch [Microsoft.PowerShell.Commands.UserNotFoundException] {
    "Local Account $($USERNAME) was not found" | Write-Host
}



#Stops PowerShell if there is an error 
Catch {
    "An unspecifed error occured" | Write-Error
    Exit 
}

#Enable Disabled Users
#Retrieves the list of Disabled Users and Re-enables the user if the username is an exact match to "MyTechPro" or "Software"
#If the account doesn't have Admin rights, It adds the user to the local admin Group
$DisabledUsers = get-wmiobject -Class win32_useraccount -filter "localaccount='true'" | Select Name, Disabled
 
 Foreach ($user in $DisabledUsers){ 

Get-LocalUser |?{$_.Name -Match "$USERNAME"} | Enable-LocalUser 
    Add-LocalGroupMember -Group "Administrators" -Member $USERNAME -ErrorAction SilentlyContinue

Get-LocalUser |?{$_.Name -Match "$USERNAME2"} | Enable-LocalUser 
    Add-LocalGroupMember -Group "Administrators" -Member $USERNAME2 -ErrorAction SilentlyContinue
 }


#Create local Software account if the username is not found.
#if the username is found the script sets the password to what is defined in AEM
#Makes user Local Admin and password never expires 
If ($ObjLocalUser) {
 
 Set-LocalUser -Name $USERNAME -Password $SecurePassword -AccountNeverExpires -PasswordNeverExpires 1
 
#If the Software account doesn't exist then it is created and added to the local admin group
}Else {
        Write-Host "Creating Local Admin Account $($USERNAME)"
New-LocalUser -Name $USERNAME -Password $SecurePassword -AccountNeverExpires -PasswordNeverExpires -ErrorAction SilentlyContinue
Add-LocalGroupMember -Group "Administrators" -Member $USERNAME -ErrorAction SilentlyContinue
}



#Create local MyTechPro account if the username is not found.
#if the username is found the script sets the password to what is defined in AEM
#Makes user Local Admin and password never expires 
If ($ObjLocalUser2) {
 
 Set-LocalUser -Name $USERNAME2 -Password $SecurePassword2 -AccountNeverExpires -PasswordNeverExpires 1
 #if the MyTechPro account doesnt exist then it is created and added to the local admin group
}Else {
        Write-Host "Creating Local Admin Account $($USERNAME2)"
New-LocalUser -Name $USERNAME2 -Password $SecurePassword2 -AccountNeverExpires -PasswordNeverExpires -ErrorAction SilentlyContinue
Add-LocalGroupMember -Group "Administrators" -Member $USERNAME2 -ErrorAction SilentlyContinue
}

###############################################################################################
###############################################################################################
###############################################################################################

Write-host "The onboarding script is now complete"