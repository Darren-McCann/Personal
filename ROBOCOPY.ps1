<#Darren McCann 27/27/23#>
<#
.SYNOPSIS
Checks if Full_IPSMSPProd_Clean.bak has been updated recently and initiates a copy
#>

[cmdletbinding()]
param(
    [Parameter(Mandatory=$True)]
    [string]$SourceFilePath = "\\elkcrpsas01\SQL Backups\Ad-hoc",
    [Parameter(Mandatory=$True)]
    [string]$DestinationFilePath = "\\elk001sdxsql01\DB_BCKP",
    [string]$Filename = "Full_IPSMSPProd_Clean.bak"
)
#Check if file is newer
$Proceed = ($(Get-Item -Path $SourceFilePath"\"$Filename).LastWriteTime -gt $(Get-Item -Path $DestinationFilePath"\"$Filename).LastWriteTime)

#Replace File
If ($Proceed){
<#
    /J	Copies using unbuffered I/O (recommended for large files).
    /MT:1 Use a single thread 
    /IM Include modified files (differing change times).
#>
    Robocopy $SourceFilePath $DestinationFilePath $FileName /MT:1 /J /IM
}
