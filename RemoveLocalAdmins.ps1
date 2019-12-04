######################################################################
#Title: MTP Local Admins W/Administrator
#Author: Blake Pierantoni
#Date: 2018/10/5
#Description: Removes All Local Administrator Accounts
#Accounts that will be kept
#AD\Domain Admins
#.\mytechpro
#.\software
#.\administrator
######################################################################


$remove = net localgroup administrators | select -skip 6 | ? {$_ -and $_ -notmatch 'successfully|^AD\\(?:domain admins)$|^administrator$|^mytechpro$|^software$'}

# remove the accounts
foreach ($user in $remove) {
    net localgroup administrators "`"$user`"" /delete
    }