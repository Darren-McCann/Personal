<#
.SYNOPSIS
Brief Description
.DESCRIPTION
Detailed description of the logic of the script or function
.PARAMETER
Parameter for input
.EXAMPLE
Example of script usage
#>
[cmdletbinding()]#For advanced scripts allowing extra built in commands
param (
    [Parameter(Mandatory=$True)]
    [Alias('Hostname')]
    [string]$Computername   #Defines the Mandatory parameter $Computername
                            # has an alias of $Hostname and is a String
    
)#Parameter block
Begin{
    Write-verbose "Connecting to $Computername"
    Write-Verbose "Querying network adapters"
}
Process{
    Get-CimInstance -class Win32_NetworkAdapter -ComputerName $Computer |
        Where-Object {$_.PhysicalAdapter} |
        Select-Object MACAddress,AdapterType,DeviceID,Name,Speed
}
End{
    Write-Verbose "Complete"
}
