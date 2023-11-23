Function Add-ManagementGroupmembers {
    [cmdletbinding()]
    param(
        [Alias('Name')]
        [Parameter(
            Mandatory=$True,
            ValueFromPipeline,
            ValueFromPipelinebyPropertyName
            )][String[]]$ComputerName
    )

    ForEach ($Computer in $ComputerName) {
        Switch ($Computer.ComputerName.Split(".")[1]) {
            "CORP" {$Prefix = "crp"}
            "PROD" {$Prefix = "prd"}
            "IPSMerchant" {$Prefix = "prd"}
            "SDX" {$Prefix = "sdx"}
        }
        
        Write-Host "$Prefix-$($Computer.Computername.Split(".")[0])-adm"
        Write-Host "$Prefix-$($Computer.Computername.Split(".")[0])-usr"
        Write-Host "$($Computer.AdminMembers)"
    }

    
}