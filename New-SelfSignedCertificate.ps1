<#
    .SYNOPSIS
        Generate a New Self Signed Certificate for localhost by FQDN and then Copy to the Trusted Root Store

    .DESCRIPTION
        The script generates a new self signed certificate based on the FQDN using ([System.Net.Dns]::GetHostByName((hostname)).HostName) so that it can grab the FQDN of a server regardless of
        the domain name. The script uses -OutVariable to assign the object to $NewCert and uses the thumbprint of the cert as an identifier of which cert to Copy to the Trust Root Store. Using the 
        thumbprint ensures that the cert being copied is the exact certificate that was just created. 

    .EXAMPLE 
        Create Certificate, Set out variable of the Certificate to NewCert, Grab Thumb Print of the Cert and use .Net to Copy the Certificate to the trusted root. 
        

 #>
function New-Certificate {
    param (
        
        [Parameter(Mandatory=$true, Position=0)]
        [string] $CertName,
        [Parameter(Mandatory=$true, Position=1)]
        [String]$CertStore,
        [Parameter(Mandatory=$true, Position=2)]
        [string]$SourceStoreScope,
        [Parameter(Mandatory=$true, Position=3)]
        [string]$SourceStoreName,
        [Parameter(Mandatory=$true, Position=4)]
        [string]$DestStoreScope,
        [Parameter(Mandatory=$true, Position=5)]
        [string]$DestStoreName
    )
    

    New-SelfsignedCertificate -DnsName $CertName -CertStoreLocation $CertStore -OutVariable NewCert
        write-host "The New Cert ThumbPrint is:" $NewCert.Thumbprint

    $SourceStore = New-Object  -TypeName System.Security.Cryptography.X509Certificates.X509Store  -ArgumentList $SourceStorename, $SourceStoreScope
        
    $SourceStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)
 
        $cert = $SourceStore.Certificates | Where-Object  -FilterScript {
            $_.thumbprint -like $NewCert.Thumbprint
        }
     
     
         $DestStore = New-Object  -TypeName System.Security.Cryptography.X509Certificates.X509Store  -ArgumentList $DestStoreName, $DestStoreScope
    
    $DestStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
         $DestStore.Add($cert)
     $SourceStore.Close()
    $DestStore.Close()

}

$NewCertificateArgs =  @{
    CertName = ([System.Net.Dns]::GetHostByName((hostname)).HostName)
    CertStore = "Cert:\LocalMachine\my"
    SourceStoreScope = "LocalMachine"
    SourceStoreName = "My"
    DestStoreScope = "LocalMachine"
    DestStoreName = "root"

    }

New-Certificate @NewCertificateArgs