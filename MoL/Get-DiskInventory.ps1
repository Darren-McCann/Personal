Get-CimInstance -class Win32_LogicalDisk ComputerName $env:COMPUTERNAME `
    -filter "drivetype=3" | Sort-Object -Property DeviceID |
    Format-Table -Property DeviceID,
    @{label='FreeSpace(MB)';expression={$_.FreeSpace / 1MB -as [int]}},
    @{label='Size(GB)';expression={$_.Size / 1GB -as [int]}},
    @{label='%Free';expression={$_.FreeSpace / $_.Size * 100 -as [int]}}