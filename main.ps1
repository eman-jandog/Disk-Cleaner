# Environment variables
$DISKPART_CONFIG = "./diskpart.conf"
$LOGFILE = "disks_record.txt"
$today = $(Get-Date -Format "MM-dd-yy")
$DRIVELETTER = "Z:" 

# Check for administrative privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Take initial snapshot of disk serial numbers
$initialDisks = Get-PhysicalDisk | Select-Object -ExpandProperty SerialNumber
$added = $null

# Loop to detect new drive in real time
while (-not $added) {
    Write-Host "Please connect the new drive..."
    
    # Scan for new disks
    $newDisks = Get-PhysicalDisk | Select-Object -ExpandProperty SerialNumber

    # Filter
    $added = $newDisks | Where-Object { $_ -notin $initialDisks }

    if ($added) {
        Write-Host "New disk(s) detected:" -ForegroundColor Green
        Start-Sleep -Seconds 1
        # Run diskpart
        diskpart.exe /s $DISKPART_CONFIG

        Start-Sleep -Seconds 1

        # Remove process related with the drive - safe to dismount even connected
        Get-WmiObject -Query "SELECT * FROM Win32_Volume WHERE DriveLetter = '$DRIVELETTER'" | ForEach-Object { $_.Dismount($false, $false) }
        
        Start-Sleep -Seconds 1

        # Record Disk 
        Echo $added >> "C:\$($today)_$($LOGFILE)"
        
        # Reset values
        $added = $null
        Start-Sleep -Seconds 1
        $initialDisks = $newDisks
        clear
    } else {
        $initialDisks = $newDisks
    }
}

