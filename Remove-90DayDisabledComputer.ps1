#Darren McCann 2023-Feb-15#
#Requires -Modules ActiveDirectory
<#
.SYNOPSIS
Gathers Disabled AD Computer Objects that have not been modified in >90 days and
removes them from AD
.DESCRIPTION
Queries the _Disabled Computers container for objects with a modified date of
greater than 90 days.
.PARAMETER Domain
Domain to query ("CORP","PROD","IPSMerchant","SDX","UAT")
.PARAMETER Logpath
Path to store Logfile (Default C:\ADLogs)
.EXAMPLE
.\Remove-90DayDisabledComputer.ps1 -Domain 'CORP'
Removes computer accounts in the '_Disabled Computers' Container in corp.payroc.com
That have not ben disabled and not modified in the last 90 days
#>
[cmdletbinding()]
param (
    [Parameter(Mandatory=$True)]
    [Validateset("CORP", "PROD", "IPSMerchant","SDX","UAT")] $Domain,
    [string]$LogPath = "C:\ADLogs"     
)#Parameter block
Begin {
    IF ($Domain -eq "IPSMerchant"){
        $Domain = Get-ADDomain -Identity IPSMerchant.local
    } Else {
        $Domain = Get-ADDomain -Identity "$($Domain).payroc.com"
    }    
    $OU = Get-ADOrganizationalUnit -Filter 'Name -like "_Disabled Computers"' `
        -Server $Domain.InfrastructureMaster
    #Get Disabled Computer Objects with a modified date greater than 90 ago
    $Computers = Get-ADComputer -Searchbase $OU.DistinguishedName`
        -Server $Domain.InfrastructureMaster`
        -Properties Modified,OperatingSystem `
        -Filter '(Enabled -eq "False") -and (ObjectClass -eq "Computer")' |
        Where-Object {$_.Modified -lt $((Get-Date).adddays(-90))}
}
Process{
    #Remove each Computer account
    ForEach ($Computer in $Computers){
        Remove-ADObject -Identity $Computer -Confirm:$False
    }
}
End{
    Write-Host -ForegroundColor Green "The following computer accounts have been removed"
    $Computers | Format-Table Name,OperatingSystem,Modified

    #Log to file
    $LogFile = "$LogPath\RemovedComputers_$(Get-Date -Format yyyy-MM-dd).csv"
    If (Test-Path $LogPath) {
        $Computers | Select-Object Name,OperatingSystem,Modified |
         Export-CSV $LogFile
    } Else {
        New-item -Path $Logpath -Type Directory
        $Computers | Select-Object Name,OperatingSystem,Modified |
         Export-CSV $LogFile
    }   
}