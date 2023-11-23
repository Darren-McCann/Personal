#Darren McCann 2023-Jan-26#
#Requires -Modules ActiveDirectory
<#
.SYNOPSIS
Gathers AD Accounts that have been in recent use
.DESCRIPTION
Queries the AD for accounts with a lastlogontimestamp of less
than the specified number of days from today. Default is 120 days.
.PARAMETER Days
Days since lastlogontimestamp (Default 120)
.PARAMETER Logpath
Path to store Logfile (Default C:\ADLogs)
.EXAMPLE
.\Get-OldADAccount.ps1 -Days 60 -LogPath "$ENV:\USERPROFILE\Documents"
Finds AD account that have logged into AD in the last 60 days and logs
to current users Documents folder
#>
[cmdletbinding()]
param (
    [int]$Days = 120,  
    [string]$LogPath = "C:\ADReports"     
)#Parameter block
Begin{
    $Domain = Get-ADDomain
    $Date = (Get-Date).AddDays(-$Days)
    
}
Process{
    #Get Computer Objects with a timestamp of less than $days ago
    $Computers = Get-ADComputer -Filter {PasswordLastSet -gt $Date}`
     -Searchbase $Domain.DistinguishedName`
     -Properties Name,OperatingSystem,OperatingSystemVersion,IPV4Address,
     DistinguishedName,PasswordLastSet
    
    #Get Enabled Users
    $EnabledUsers = Get-ADUser -Filter {Enabled -eq "True"}`
     -Searchbase $Domain.DistinguishedName`
     -Properties DisplayName,SamAccountName,UserPrincipalName,
     GivenName,Surname,Mail,DistinguishedName,Title,PhysicalDeliveryOfficeName,
     Company,City,Department,Description,Manager

}
End{
    #Log to file
    $LogComputersFile = "$LogPath\ActiveComputers_$(Get-Date -Format yyyy-MM-dd).csv"
    $LogUsersFile = "$LogPath\ActiveUsers_$(Get-Date -Format yyyy-MM-dd).csv"
    If (Test-Path $LogPath) {
        $Computers | Select-Object -Property Name,Operatingsystem,OperatingSystemVersion,
        IPv4Address,DistinguishedName,PasswordLastSet |
         Export-CSV $LogComputersFile -NoTypeInformation
        
         $EnabledUsers | Select-Object DisplayName,SamAccountName,UserPrincipalName,GivenName,
        Surname,mail,DistinguishedName,Title,physicalDeliveryOfficeName,company,City,Department,
        Description,Manager |
         Export-CSV $LogUsersFile -NoTypeInformation
         
    } Else {
        New-item -Path $Logpath -Type Directory
        $Computers | Select-Object -Property Name,Operatingsystem,OperatingSystemVersion,
        IPv4Address,DistinguishedName,PasswordLastSet |
         Export-CSV $LogComputersFile -NoTypeInformation

        $EnabledUsers | Select-Object DisplayName,SamAccountName,UserPrincipalName,GivenName,
        Surname,mail,DistinguishedName,Title,physicalDeliveryOfficeName,company,City,Department,
        Description,Manager |
         Export-CSV $LogUsersFile -NoTypeInformation
    }   
}
