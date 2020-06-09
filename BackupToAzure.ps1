<#
    .SYNOPSIS
        Powershell script for copying backups or files from a server to an Azure Storage Container using AZCopy

    .DESCRIPTION
        The powershell script uses AZ Copy to upload files to an Azure Storage Container. The scipt uses an
        Azure Application Service Principle for authentication and authorization to the azure domain and space.
        This process can be automated by converting the script into an executable and running it with Windows 
        Task Scheduler.  


    .REQUIREMENTS 
        1. AZCopy downloaded and Placed in Program Files
        2. System Path Environment variable for AZCopy
        3. Valid Azure Application Service Principle with rights to the Storage Container

    .SYNTAX 
        Authentication and Authorization
          azcopy login --service-principal --application-id <application-id> --tenant-id=<tenant-id>

        Upload A Directory   
          azcopy copy '<local-directory-path>' 'https://<storage-account-name>.<blob or dfs>.core.windows.net/<container-name>' --recursive
     
    
   .LINK 
    https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10
   
   .Example .\BackupToAzure.ps1 -backupLoc C:\Backup 

 #>
param (
	[Parameter(Mandatory=$true)]
	[string]$backupLoc
)


function Copy-Backup {
    param (
       
        # Parameter help description
        [Parameter(Mandatory=$true, Position=0)]
        [string] $ClientSecret,
        # Parameter help description
        [Parameter(Mandatory=$true, Position=1)]
        [string] $AppID, 
        # Parameter help description
        [Parameter(Mandatory=$true, Position=2)]
        [string] $TenantID,
         # Parameter help description
        [Parameter(Mandatory=$true, Position=3)]
        [string] $ContainerName
    )

        $env:AZCOPY_SPA_CLIENT_SECRET=$ClientSecret
        azcopy login --service-principal --application-id $AppID --tenant-id=$TenantID
        azcopy copy "$backupLoc" "https://$yourcontainerURL.blob.core.windows.net/$($ContainerName)" --recursive --overwrite=false --log-level ERROR
}



$CopyBackupArguments = @{

    ClientSecret = "$YourClientSecret"
    AppID = "$YourAppID"
    TenantID = "$YourTenantID"
    ContainerName = $env:COMPUTERNAME.ToLower()


}

Copy-Backup @CopyBackupArguments