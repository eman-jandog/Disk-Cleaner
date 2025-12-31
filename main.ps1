# Environment variables
$DISKPART_CONFIG = "./diskpart.conf"

# Check for administrative privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Take initial snapshot of disk serial numbers
$initialDisks = Get-PhysicalDisk | Select-Object -ExpandProperty SerialNumber
$added = $null

# Loop to detect new drive in real time
Write-Host "Please connect the new drive..."
while (-not $added) {

    # Scan for new disks
    $newDisks = Get-PhysicalDisk | Select-Object -ExpandProperty SerialNumber

    # Filter
    $added = $newDisks | Where-Object { $_ -notin $initialDisks }

    if ($added) {
        Write-Host "New disk(s) detected:" -ForegroundColor Green
        $initialDisks = $newDisks

        # Run diskpart
        diskpart.exe /s $DISKPART_CONFIG

        Start-Sleep -Seconds 2

        # Remove process related with the drive - safe to dismount even connected
        $driveLetter = "Z:" 
        Get-WmiObject -Query "SELECT * FROM Win32_Volume WHERE DriveLetter = '$driveLetter'" | ForEach-Object { $_.Dismount($false, $false) }
        
        # Reset values
        $added = $null
        clear

    } else {
        
        $initialDisks = $newDisks
    }
}

