#Darren McCann 2023-Jan-25#
#Requires -Modules ActiveDirectory
<#
.SYNOPSIS
Gathers AD Computer Objects that have not been in recent use and disables it
.DESCRIPTION
Queries the Computers container for objects with a lastlogontimestamp of greater
than the specified number of days from today. Default is 30 days.
Desktop OS' are excluded from this query as VPN users can have a timestamp
longer than this
.PARAMETER Domain
Domain to query ("CORP","PROD","IPSMerchant","SDX","UAT")
.PARAMETER Days
Days since lastlogontimestamp (Default 30)
.PARAMETER Logpath
Path to store Logfile
.EXAMPLE
.\Disable-30DayADAccount.ps1 -Days 60 -Domain Prod
Disables the Computer account of any account that has a lastlogontimestamp of
more than 60 days ago in prod.payroc.com domain
#>
[cmdletbinding()]
param (
    [int]$Days = 30,
    [Parameter(Mandatory=$True)]
    [Validateset("CORP", "PROD", "IPSMerchant","SDX","UAT")] $Domain, 
    [string]$LogPath = "C:\ADLogs"     
)#Parameter block
Begin{
    IF ($Domain -eq "IPSMerchant"){
        $Domain = Get-ADDomain -Identity IPSMerchant.local
    } Else {
        $Domain = Get-ADDomain -Identity "$($Domain).payroc.com"
    }
    #Get Computer Objects that are not running a Windows Desktop or Mac OS
    #With a timestamp greater than $days ago
    $Computers = Get-ADComputer -Filter {OperatingSystem -notlike "Windows 1*"
     -and OperatingSystem -notlike "MacOS"}`
     -Searchbase $Domain.ComputersContainer`
     -Server $Domain.InfrastructureMaster`
     -Properties LastlogonTimeStamp,OperatingSystem |
     Where-Object {[datetime]::FromFileTime($_.lastlogontimestamp) -lt $((Get-Date).adddays(-$Days))}
     
    #Test for existence of a holding OU, else use the Computers Contianer
    if (Get-ADOrganizationalUnit -filter 'name -like "_Disabled Computers"'){
        $DisabledOU = (Get-ADOrganizationalUnit -filter 'name -like "_Disabled Computers"')
    } Else {
        $DisabledOU = @{DistinguishedName = $Domain.ComputersContainer}
    }
}
Process{
    #Disable each Computer account and move the object to the holding area
    ForEach ($Computer in $Computers){
        Disable-ADObject -Identity $Computer.SamAccountName
        Move-ADObject -Identity $Computer.ObjectGUID`
         -TargetPath $DisabledOU.DistinguishedName

    }

}
End{
    Write-Host -ForegroundColor Green "The following computer accounts have been disabled"
    $Computers | Format-Table Name,OperatingSystem,@{Label="LastLogonTimestamp";Expression={[DateTime]::FromFileTime($_.LastLogonTimestamp)}}

    #Log to file
    $LogFile = "$LogPath\DisabledComputers_$(Get-Date -Format yyyy-MM-dd).csv"
    If (Test-Path $LogPath) {
        $Computers | Select-Object Name,OperatingSystem,@{Label="LastLogonTimestamp";Expression={[DateTime]::FromFileTime($_.LastLogonTimestamp)}} |
         Export-CSV $LogFile
    } Else {
        New-item -Path $Logpath -Type Directory
        $Computers | Select-Object Name,OperatingSystem,@{Label="LastLogonTimestamp";Expression={[DateTime]::FromFileTime($_.LastLogonTimestamp)}} |
         Export-CSV $LogFile
    }   
}
