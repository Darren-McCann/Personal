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
    [string]$Computername,  #Defines the Mandatory parameter $Computername
                            # has an alias of $Hostname and is a String
    [Validateset(2,3)]
    [int]$Integer = 3       #Defines $Interger to default to 3 and will only 
                            #accept an integer or 2 or 3
)#Parameter block
Begin{

}
Process{

}
End{
    
}