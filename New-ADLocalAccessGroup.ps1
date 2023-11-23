
<#
.SYNOPSIS
Creates Groups for use with granular server access from Active Directory
.DESCRIPTION
Gathers all active Servers and creates two groups
One for use in the Local Administrators of the target server
One for use in the Remote Desktop Users of the target server 
.PARAMETER Domain
Domain to query. Valid options are CORP, PROD, IPSMerchant or All
All will query both CORP & PROD only as IPSMerchant is being retired
for future deployments
.PARAMETER Logpath
Filepath to store log of new groups created
.EXAMPLE
.\New-ADLocalAccessGroup -Domain Corp
Will get all active Windows Server computer accounts and create a 
valid group for local admin and rdp users if it does not already exist
#>
[cmdletbinding()]
param (
    [Parameter(Mandatory=$True)]    
    [Validateset("CORP", "PROD", "All")] $Domain,
    [string]$LogPath = "C:\ADLogs"
)

Begin {
    #Set parameters for domain to query
    Switch ($Domain) {
        "CORP" {
            $Searchbase = "OU=SITES,OU=PAYROC,DC=CORP,DC=PAYROC,DC=COM"
            $DCServer = "mkmcrpdmc02.CORP.PAYROC.COM"
        }
        "PROD" {
            $Searchbase = "OU=SITES,OU=PAYROC,DC=PROD,DC=PAYROC,DC=COM"
            $DCServer = "elkprddmc01.prod.payroc.com"
        }
               
    }
    #Import ActiveDirectory Module
    Import-Module Activedirectory
    If ($Domain -eq "All") {
        #If All, gather computer names from both CORP & PROD
        $Servers = Get-ADComputer -SearchBase "OU=SITES,OU=PAYROC,DC=CORP,DC=PAYROC,DC=COM"`
         -Server "mkmcrpdmc02.CORP.PAYROC.COM" -Filter { Enabled -eq "True" }`
          -Properties OperatingSystem |
            Where-Object {$_.OperatingSystem -Like "Windows Server*"}
        $Servers += Get-ADComputer -SearchBase "OU=SITES,OU=PAYROC,DC=PROD,DC=PAYROC,DC=COM"`
         -Server "elkprddmc01.prod.payroc.com" -Filter { Enabled -eq "True" }`
          -Properties OperatingSystem |
            Where-Object {$_.OperatingSystem -Like "Windows Server*"}

    } Else {
        #Else gather computer from only specified domain
        $Servers = Get-ADComputer -SearchBase $Searchbase -Server $DCServer `
         -Filter { Enabled -eq "True" } -Properties OperatingSystem |
            Where-Object {$_.OperatingSystem -Like "Windows Server*"}
    }
    $NewGroups = "The following new groups have been created:`n"  
}

Process {

    ForEach ($Server in $Servers) {
        #Get prefix code based on DNS Domain
        switch ($Server.DNSHostName.Split(".")[1]) {
            "PROD" { $Prefix = "prd" }
            "CORP" { $Prefix = "crp" }
        }

        #Generate group names based on prefix and server name
        $Admin = "$Prefix-$($Server.Name)-adm".ToLower()
        $RDP = "$Prefix-$($Server.Name)-usr".ToLower()
        
        #Check if Admin group exists
        Try {
            $Group = Get-ADGroup -Identity $Admin
            If ($Group) {
                Write-Host -ForegroundColor Yellow "$Admin already exists!"
            }
        }
        #If no group exists, create it
        Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
            New-ADGroup -Name $Admin -GroupCategory Security -GroupScope Universal `
             -Path "OU=Local Administrators,OU=Groups,OU=Global,OU=Payroc,DC=CORP,DC=PAYROC,DC=COM" `
             -Description "Provides Local Administrator permissions for $($Server.DNSHostName)"
            $NewGroups += "$Admin`n"
        }
        #Add any default members
        Add-ADGroupMember -Identity $Admin -Members "sys_eng-mgt" 

        #Check if RDP Users group exists
        Try {
            $Group = Get-ADGroup -Identity $RDP
            If ($Group) {
                Write-Host -ForegroundColor Yellow "$RDP already exists!"
            }
        }
        #if no group exists, create it
        Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
            New-ADGroup -Name $RDP -GroupCategory Security -GroupScope Universal `
            -Path "OU=Remote Desktop Users,OU=Groups,OU=Global,OU=Payroc,DC=CORP,DC=PAYROC,DC=COM" `
            -Description "Provides RDP permissions for $($Server.DNSHostName)"
            $NewGroups += "$RDP`n"
        }
        #Add-ADGroupMember -Identity $RDP -Members "Test-User" -Verbose
    }
}
End{
    #Log to file
    $LogFile = "$LogPath\New_ADGroups_$(Get-Date -Format yyyy-MM-dd).txt"
    If (Test-Path $LogPath) {
        $NewGroups | Out-File $LogFile
    } Else {
        New-item -Path $Logpath -Type Directory
        $NewGroups | Out-File $LogFile
    }   
}

