#################################################################
# Title: Find Local Admins
# Author: Blake Pierantoni
# Date: 2019/08/26
# Description: Look for computers in AD and create a CSV of local admins on the machines. 
#################################################################


Import-module ActiveDirectory
$computers = Get-ADComputer -Filter *
$LocalGroupName = "Administrators"

$OutputDir = "c:\working"
$OutputFile = Join-Path $OutputDir "LocalGroupMembers.csv"
Write-Verbose "Script will write the output to $OutputFile folder"
Add-Content -Path $OutPutFile -Value "ComputerName, LocalGroupName, Status, MemberType, MemberDomain, MemberName"

foreach ($computer in $computers) 
    {
        $computerName = $computer.name
		If(!(Test-Connection -ComputerName $computerName -Count 1 -Quiet)) {
			Add-Content -Path $OutputFile -Value "$computerName,$LocalGroupName,Offline"
		Continue
		} 
		else {
			try {
				$group = [ADSI]"WinNT://$computerName/$LocalGroupName"
				$members = @($group.Invoke("Members"))
				if(!$members) {
					Add-Content -Path $OutputFile -Value "$Computer,$LocalGroupName,NoMembersFound"
					Continue
				}
			}
			catch {
				Add-Content -Path $OutputFile -Value "$computerName,,FailedToQuery"
				Continue
			}
			foreach($member in $members) {
				try {
					$MemberName = $member.GetType().Invokemember("Name","GetProperty",$null,$member,$null)
					$MemberType = $member.GetType().Invokemember("Class","GetProperty",$null,$member,$null)
					$MemberPath = $member.GetType().Invokemember("ADSPath","GetProperty",$null,$member,$null)
					$MemberDomain = $null
					If($MemberPath -match "^Winnt\:\/\/(?<domainName>\S+)\/(?<CompName>\S+)\/") {
						if($MemberType -eq "User") {
							$MemberType = "LocalUser"
						} elseif($MemberType -eq "Group"){
							$MemberType = "LocalGroup"
						}
						$MemberDomain = $matches["CompName"]
					} elseif($MemberPath -match "^WinNT\:\/\/(?<domainname>\S+)/") {
						if($MemberType -eq "User") {
							$MemberType = "DomainUser"
						} elseif($MemberType -eq "Group"){
							$MemberType = "DomainGroup"
						}
						$MemberDomain = $matches["domainname"]
					} else {
						$MemberType = "Unknown"
						$MemberDomain = "Unknown"
					}
					If ($MemberName -notlike "Domain Admins" -and $MemberName -notlike "Enterprise Admins" -and $MemberName -notlike "redtower1"-and $MemberName -notlike "Administrator" -and $MemberName -notlike "WorkstationAdmins" -and $MemberName -notlike "ServerAdmins")	{
					Add-Content -Path $OutPutFile -Value "$computerName, $LocalGroupName, SUCCESS, $MemberType, $MemberDomain, $MemberName"
					}
				} catch {
				Add-Content -Path $OutputFile -Value "$Computer,,FailedQueryMember"
				}
    		}
		}
		}
