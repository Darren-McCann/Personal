#Darren McCann 02/20/23
<#
.SYNOPSIS
Gathers membership data for Local Admin & Remote Desktop Users of a remote computer
.DESCRIPTION
Gathers membership data for Local Admin & Remote Desktop Users of a remote computer
.PARAMETER
Name
Name, or list of names of computers to query. Can accept values from pipeline.
.EXAMPLE
Get-AdComputer -Filter * | .\Get-RemoteGroupMember.ps1
Processes all compiters from ADQuery
.EXAMPLE
.\Get-RemoteGroupMember.ps1 -Name 'Server01','Server02'
Queries given computers
#>
[cmdletbinding()]
param(
        [Alias('ComputerName','Name')]
        [Parameter(
            Mandatory=$True,
            ValueFromPipeline=$True,
            ValueFromPipelinebyPropertyName=$True
            )][String[]]$DNSHostName,
        [System.Management.Automation.PSCredential]$Credential
    )
Begin {
    If (!$Credential){
        $Credential = Get-Credential -Message "Please enter valid domain credentials:"
    }
}
Process {      
    Invoke-Command -ScriptBlock {
        #Enumerate local group members
        $Admins = net localgroup "Administrators" |
            Where-Object {$_ -and $_ -notmatch "command completed successfully"} |
            Select-Object -Skip 4
        $RDPUsers = net localgroup "Remote Desktop Users" |
           Where-Object {$_ -and $_ -notmatch "command completed successfully"} |
            Select-Object -Skip 4 

        #Gather Details for Object
        $Members =  @{
                    ComputerName = $ENV:Computername+"."+$ENV:USERDNSDOMAIN
                    AdminGroup = "Administrators"
                    AdminMembers = $Admins
                    RdPGroup = "Remote Desktop Users"
                    RDPMembers = $RDPUsers
        }
         $LocalGroups = [PSCustomObject]$Members

        #Store Data in Array
               
        Return $LocalGroups

    } -ComputerName $Name -HideComputerName -Credential $Credential |
        #Remove Runspace ID value from results
        Select-Object * -ExcludeProperty RunspaceID
}
End {}