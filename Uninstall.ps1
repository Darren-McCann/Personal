<#Darren McCann 06/15/23#>
<#Checks for presence of LANDesk Management Agent
If it is present, run uninstaller from Domain share
Pause for removal to complete
Check files have been removed and log upon completion#>

If (Test-Path "C:\Program Files (x86)\LANDesk\Shared Files\residentagent.exe") {
	
	#Stop Running LANDesk processes
	$ProcessIDs = (Get-ciminstance -ClassName win32_process | Where-Object {$_.Path -like 'C:\Program Files (x86)\LANDesk\*'}).ProcessID
	$ProcessIDs | ForEach {Taskkill /pid $_ /f}
	#Run the uninstaller
	\\ELKSDXDMC01\GPO_Distribution\Uninstall_Ivanti\UninstallWinClient.exe /FORCECLEANUP /NOREBOOT
	
	Start-Sleep -s 300
	
	#Cleanup any remaining files
	Remove-Item -path 'C:\Program Files (x86)\LANDesk\' -Recurse -Force
	Remove-Item -path "HKLM:\SOFTWARE\WOW6432Node\landesk\" -Recurse
	Remove-Item -path "HKLM:\SOFTWARE\WOW6432Node\Intel\LANDesk\" -Recurse
	
	#Log results
    $Log = $(Get-Date ([datetime]::UtcNow) -Format "MM/dd/yyyy,HH:mm:ss") + "," + $env:COMPUTERNAME
	If (Test-Path "C:\Program Files (x86)\LANDesk\") {
		#Log Failures if service path still exists
		Add-Content -Path "\\ELKSDXDMC01\GPO_Distribution\Uninstall_Ivanti\Failed.csv" -Value $LOG
	} Else {
		#Log successful cleanup
        Add-Content -Path "\\ELKSDXDMC01\GPO_Distribution\Uninstall_Ivanti\Complete.csv" -Value $LOG
    }
}