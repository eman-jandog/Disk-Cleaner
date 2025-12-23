# Check for administrative privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Take initial snapshot of disk serial numbers
$initialDisks = Get-PhysicalDisk | Select-Object -ExpandProperty SerialNumber
$added = $null
Write-Host "Please connect the new drive..."
while (-not $added) {
    #Start-Sleep -Seconds 10 
    $newDisks = Get-PhysicalDisk | Select-Object -ExpandProperty SerialNumber
    $added = $newDisks | Where-Object { $_ -notin $initialDisks }

    if ($added) {
        Write-Host "New disk(s) detected:" -ForegroundColor Green
        $initialDisks = $newDisks
        # Run diskpart
        diskpart.exe /s ./cleanDisk.conf
        Start-Sleep -Seconds 2
        $driveLetter = "Z:" 
        Get-WmiObject -Query "SELECT * FROM Win32_Volume WHERE DriveLetter = '$driveLetter'" | ForEach-Object { $_.Dismount($false, $false) }
        $added = $null
        clear
        # Get-PhysicalDisk | Where-Object { $_.SerialNumber -in $added } |
        #     Select FriendlyName, SerialNumber, Size | Format-Table
    } else {
        $initialDisks = $newDisks
    }
}

