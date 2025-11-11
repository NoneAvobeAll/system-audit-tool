<#
.SYNOPSIS
    Windows System Slowness Audit Tool - Enhanced Edition
.DESCRIPTION
    Advanced performance audit tool for diagnosing system slowness on Windows servers, laptops, and desktops.
    Developed by: Abubakkar Khan - System Engineer | Cybersecurity Researcher
.VERSION
    1.0.3
#>

# Requires -RunAsAdministrator

# Color scheme
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "White"
Clear-Host

function Show-Banner {
    Write-Host "╔═══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                                                                       ║" -ForegroundColor Cyan
    Write-Host "║          WINDOWS SYSTEM SLOWNESS AUDIT TOOL v1.0.3                    ║" -ForegroundColor Yellow
    Write-Host "║                                                                       ║" -ForegroundColor Cyan
    Write-Host "║          Developed By: Abubakkar Khan                                 ║" -ForegroundColor Green
    Write-Host "║          System Engineer | Cybersecurity Researcher                   ║" -ForegroundColor Green
    Write-Host "║                                                                       ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Show-Menu {
    Write-Host "═══════════════════ AUDIT OPTIONS ═══════════════════" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "  [1]  CPU Usage Analysis" -ForegroundColor White
    Write-Host "  [2]  Memory (RAM) Analysis" -ForegroundColor White
    Write-Host "  [3]  Disk Performance and Space Analysis" -ForegroundColor White
    Write-Host "  [4]  Network Performance Analysis" -ForegroundColor White
    Write-Host "  [5]  Top Resource-Consuming Processes" -ForegroundColor White
    Write-Host "  [6]  Windows Services Status Check" -ForegroundColor White
    Write-Host "  [7]  System Event Log Errors (Last 24h)" -ForegroundColor White
    Write-Host "  [8]  Startup Programs Analysis" -ForegroundColor White
    Write-Host "  [9]  Windows Update Status" -ForegroundColor White
    Write-Host "  [10] Temperature and Hardware Health (WMI)" -ForegroundColor White
    Write-Host ""
    Write-Host "  ===== ADVANCED DIAGNOSTICS (NEW) =====" -ForegroundColor Yellow
    Write-Host "  [13] PageFile and Virtual Memory Analysis" -ForegroundColor Cyan
    Write-Host "  [14] System Uptime and Boot Performance" -ForegroundColor Cyan
    Write-Host "  [15] Network Latency and Packet Loss Test" -ForegroundColor Cyan
    Write-Host "  [16] Antivirus and Windows Defender Impact" -ForegroundColor Cyan
    Write-Host "  [17] Process Handle and Thread Analysis" -ForegroundColor Cyan
    Write-Host "  [18] Scheduled Tasks Analysis" -ForegroundColor Cyan
    Write-Host "  [19] Power Plan and Battery Status" -ForegroundColor Cyan
    Write-Host "  [20] DNS Resolution Performance Test" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [11] ** FULL SYSTEM AUDIT (All Checks) **" -ForegroundColor Yellow
    Write-Host "  [12] Export Report to File" -ForegroundColor Green
    Write-Host "  [0]  Exit" -ForegroundColor Red
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Magenta
}

function Get-CPUUsage {
    Write-Host "`n[+] CPU USAGE ANALYSIS" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    
    $cpu = Get-CimInstance Win32_Processor
    $cpuLoad = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
    
    Write-Host "CPU Model      : $($cpu.Name)" -ForegroundColor White
    Write-Host "Cores/Threads  : $($cpu.NumberOfCores) Cores / $($cpu.NumberOfLogicalProcessors) Logical Processors" -ForegroundColor White
    Write-Host "Current Load   : $([math]::Round($cpuLoad, 2))%" -ForegroundColor $(if($cpuLoad -gt 80){"Red"}elseif($cpuLoad -gt 60){"Yellow"}else{"Green"})
    Write-Host "Max Clock Speed: $($cpu.MaxClockSpeed) MHz" -ForegroundColor White
    Write-Host "Current Speed  : $($cpu.CurrentClockSpeed) MHz" -ForegroundColor White
    
    # CPU Queue Length
    try {
        $cpuQueue = (Get-Counter '\System\Processor Queue Length').CounterSamples.CookedValue
        Write-Host "CPU Queue Len  : $cpuQueue" -ForegroundColor $(if($cpuQueue -gt 5){"Red"}elseif($cpuQueue -gt 2){"Yellow"}else{"Green"})
        if($cpuQueue -gt 5) {
            Write-Host "(WARNING) High CPU queue indicates CPU bottleneck" -ForegroundColor Red
        }
    } catch {}
    
    Write-Host "`nTop 10 CPU-Consuming Processes:" -ForegroundColor Cyan
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 ProcessName, CPU, Id | Format-Table -AutoSize
    
    if($cpuLoad -gt 80) {
        Write-Host "(WARNING) CPU usage is critically high (greater than 80 percent)" -ForegroundColor Red
    } elseif($cpuLoad -gt 60) {
        Write-Host "(CAUTION) CPU usage is elevated (greater than 60 percent)" -ForegroundColor Yellow
    } else {
        Write-Host "(OK) CPU usage is within normal range" -ForegroundColor Green
    }
}

function Get-MemoryUsage {
    Write-Host "`n[+] MEMORY (RAM) ANALYSIS" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    
    $os = Get-CimInstance Win32_OperatingSystem
    $totalRAM = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $freeRAM = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $usedRAM = $totalRAM - $freeRAM
    $usagePercent = [math]::Round(($usedRAM / $totalRAM) * 100, 2)
    
    Write-Host "Total RAM      : $totalRAM GB" -ForegroundColor White
    Write-Host "Used RAM       : $usedRAM GB" -ForegroundColor White
    Write-Host "Free RAM       : $freeRAM GB" -ForegroundColor White
    Write-Host "Usage Percent  : $usagePercent%" -ForegroundColor $(if($usagePercent -gt 90){"Red"}elseif($usagePercent -gt 75){"Yellow"}else{"Green"})
    
    # Page Faults
    try {
        $pageFaults = (Get-Counter '\Memory\Page Faults/sec').CounterSamples.CookedValue
        Write-Host "Page Faults/sec: $([math]::Round($pageFaults, 2))" -ForegroundColor White
    } catch {}
    
    # Available MBytes
    try {
        $availMB = (Get-Counter '\Memory\Available MBytes').CounterSamples.CookedValue
        Write-Host "Available MB   : $([math]::Round($availMB, 2)) MB" -ForegroundColor White
    } catch {}
    
    Write-Host "`nTop 10 Memory-Consuming Processes:" -ForegroundColor Cyan
    Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 ProcessName, @{Name="Memory(MB)";Expression={[math]::Round($_.WorkingSet / 1MB, 2)}}, Id | Format-Table -AutoSize
    
    if($usagePercent -gt 90) {
        Write-Host "(CRITICAL) Memory usage is critically high (greater than 90 percent)" -ForegroundColor Red
    } elseif($usagePercent -gt 75) {
        Write-Host "(WARNING) Memory usage is high (greater than 75 percent)" -ForegroundColor Yellow
    } else {
        Write-Host "(OK) Memory usage is within acceptable range" -ForegroundColor Green
    }
}

function Get-DiskPerformance {
    Write-Host "`n[+] DISK PERFORMANCE AND SPACE ANALYSIS" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    
    $disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"
    
    foreach ($disk in $disks) {
        $size = [math]::Round($disk.Size / 1GB, 2)
        $free = [math]::Round($disk.FreeSpace / 1GB, 2)
        $used = $size - $free
        $usagePercent = [math]::Round(($used / $size) * 100, 2)
        
        Write-Host "`nDrive          : $($disk.DeviceID)" -ForegroundColor Cyan
        Write-Host "Volume Label   : $($disk.VolumeName)" -ForegroundColor White
        Write-Host "Total Space    : $size GB" -ForegroundColor White
        Write-Host "Used Space     : $used GB" -ForegroundColor White
        Write-Host "Free Space     : $free GB" -ForegroundColor White
        Write-Host "Usage Percent  : $usagePercent%" -ForegroundColor $(if($usagePercent -gt 90){"Red"}elseif($usagePercent -gt 80){"Yellow"}else{"Green"})
        
        if($usagePercent -gt 90) {
            Write-Host "(CRITICAL) Disk space critically low (less than 10 percent free)" -ForegroundColor Red
        } elseif($usagePercent -gt 80) {
            Write-Host "(WARNING) Disk space low (less than 20 percent free)" -ForegroundColor Yellow
        }
    }
    
    Write-Host "`nDisk Read/Write Performance:" -ForegroundColor Cyan
    try {
        $diskIO = Get-Counter '\PhysicalDisk(_Total)\Disk Reads/sec', '\PhysicalDisk(_Total)\Disk Writes/sec' -ErrorAction SilentlyContinue
        $readOps = [math]::Round($diskIO.CounterSamples[0].CookedValue, 2)
        $writeOps = [math]::Round($diskIO.CounterSamples[1].CookedValue, 2)
        Write-Host "Disk Reads/sec : $readOps" -ForegroundColor White
        Write-Host "Disk Writes/sec: $writeOps" -ForegroundColor White
        
        # Disk Queue Length
        $diskQueue = (Get-Counter '\PhysicalDisk(_Total)\Avg. Disk Queue Length').CounterSamples.CookedValue
        Write-Host "Disk Queue Len : $([math]::Round($diskQueue, 2))" -ForegroundColor $(if($diskQueue -gt 2){"Red"}elseif($diskQueue -gt 1){"Yellow"}else{"Green"})
        
        if($diskQueue -gt 2) {
            Write-Host "(WARNING) High disk queue indicates I/O bottleneck" -ForegroundColor Red
        }
    } catch {
        Write-Host "(INFO) Unable to retrieve disk I/O performance data" -ForegroundColor Yellow
    }
}

function Get-NetworkPerformance {
    Write-Host "`n[+] NETWORK PERFORMANCE ANALYSIS" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    
    $adapters = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}
    
    foreach ($adapter in $adapters) {
        Write-Host "`nAdapter        : $($adapter.Name)" -ForegroundColor Cyan
        Write-Host "Status         : $($adapter.Status)" -ForegroundColor Green
        Write-Host "Link Speed     : $($adapter.LinkSpeed)" -ForegroundColor White
        Write-Host "MAC Address    : $($adapter.MacAddress)" -ForegroundColor White
        
        # Get bandwidth usage
        try {
            $adapterName = $adapter.Name
            $bytesSent = Get-Counter "\Network Interface($adapterName)\Bytes Sent/sec" -ErrorAction SilentlyContinue
            $bytesRecv = Get-Counter "\Network Interface($adapterName)\Bytes Received/sec" -ErrorAction SilentlyContinue
            
            if($bytesSent) {
                $sentMBps = [math]::Round($bytesSent.CounterSamples.CookedValue / 1MB, 2)
                Write-Host "Bytes Sent/sec : $sentMBps MB/s" -ForegroundColor White
            }
            if($bytesRecv) {
                $recvMBps = [math]::Round($bytesRecv.CounterSamples.CookedValue / 1MB, 2)
                Write-Host "Bytes Recv/sec : $recvMBps MB/s" -ForegroundColor White
            }
        } catch {}
    }
    
    Write-Host "`nNetwork Connectivity Test:" -ForegroundColor Cyan
    $testConnection = Test-Connection -ComputerName "8.8.8.8" -Count 2 -Quiet
    if($testConnection) {
        Write-Host "(OK) Internet connectivity: OK" -ForegroundColor Green
    } else {
        Write-Host "(FAILED) Internet connectivity: FAILED" -ForegroundColor Red
    }
    
    Write-Host "`nActive Network Connections (ESTABLISHED):" -ForegroundColor Cyan
    $connections = Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue | Select-Object -First 10 LocalAddress, LocalPort, RemoteAddress, RemotePort, State
    $connections | Format-Table -AutoSize
}

function Get-TopProcesses {
    Write-Host "`n[+] TOP RESOURCE-CONSUMING PROCESSES" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    
    Write-Host "`nTop 15 by CPU:" -ForegroundColor Cyan
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 15 ProcessName, CPU, @{Name="Memory(MB)";Expression={[math]::Round($_.WorkingSet / 1MB, 2)}}, Id, Handles | Format-Table -AutoSize
    
    Write-Host "`nTop 15 by Memory:" -ForegroundColor Cyan
    Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 15 ProcessName, @{Name="Memory(MB)";Expression={[math]::Round($_.WorkingSet / 1MB, 2)}}, CPU, Id, Handles | Format-Table -AutoSize
}

function Get-ServicesStatus {
    Write-Host "`n[+] WINDOWS SERVICES STATUS CHECK" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    
    $criticalServices = @("wuauserv", "BITS", "EventLog", "WinDefend", "Dnscache", "Dhcp", "LanmanWorkstation", "LanmanServer", "W32Time", "RpcSs", "Spooler")
    
    Write-Host "`nCritical Services Status:" -ForegroundColor Cyan
    foreach ($svc in $criticalServices) {
        $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
        if ($service) {
            $status = $service.Status
            $color = if($status -eq "Running"){"Green"}else{"Red"}
            Write-Host "$($service.DisplayName) ($($service.Name)): " -NoNewline -ForegroundColor White
            Write-Host "$status" -ForegroundColor $color
        }
    }
    
    Write-Host "`nServices that Should be Running but are Stopped:" -ForegroundColor Cyan
    $stoppedServices = Get-Service | Where-Object {$_.StartType -eq "Automatic" -and $_.Status -eq "Stopped"}
    if ($stoppedServices.Count -gt 0) {
        $stoppedServices | Select-Object -First 20 DisplayName, Name, Status, StartType | Format-Table -AutoSize
        Write-Host "(INFO) Found $($stoppedServices.Count) stopped services with Automatic start type" -ForegroundColor Yellow
    } else {
        Write-Host "(OK) All automatic services are running" -ForegroundColor Green
    }
}

function Get-EventLogErrors {
    Write-Host "`n[+] SYSTEM EVENT LOG ERRORS (Last 24 Hours)" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    
    $startTime = (Get-Date).AddHours(-24)
    
    Write-Host "`nSystem Errors:" -ForegroundColor Cyan
    $systemErrors = Get-EventLog -LogName System -EntryType Error -After $startTime -ErrorAction SilentlyContinue | Select-Object -First 20
    if ($systemErrors) {
        $systemErrors | Select-Object TimeGenerated, Source, EventID, Message | Format-Table -AutoSize -Wrap
        Write-Host "(INFO) Found $($systemErrors.Count) system errors" -ForegroundColor Yellow
    } else {
        Write-Host "(OK) No system errors in the last 24 hours" -ForegroundColor Green
    }
    
    Write-Host "`nApplication Errors:" -ForegroundColor Cyan
    $appErrors = Get-EventLog -LogName Application -EntryType Error -After $startTime -ErrorAction SilentlyContinue | Select-Object -First 20
    if ($appErrors) {
        $appErrors | Select-Object TimeGenerated, Source, EventID, Message | Format-Table -AutoSize -Wrap
        Write-Host "(INFO) Found $($appErrors.Count) application errors" -ForegroundColor Yellow
    } else {
        Write-Host "(OK) No application errors in the last 24 hours" -ForegroundColor Green
    }
}

function Get-StartupPrograms {
    Write-Host "`n[+] STARTUP PROGRAMS ANALYSIS" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    
    Write-Host "`nStartup Programs (Registry):" -ForegroundColor Cyan
    $startupRegPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
    )
    
    $startupCount = 0
    foreach ($path in $startupRegPaths) {
        if (Test-Path $path) {
            $items = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue
            if ($items) {
                Write-Host "`nLocation: $path" -ForegroundColor White
                $items.PSObject.Properties | Where-Object {$_.Name -notmatch '^PS'} | ForEach-Object {
                    Write-Host "  $($_.Name): $($_.Value)" -ForegroundColor Gray
                    $startupCount++
                }
            }
        }
    }
    
    Write-Host "`nStartup Folder Items:" -ForegroundColor Cyan
    $startupFolders = @(
        "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup",
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
    )
    
    foreach ($folder in $startupFolders) {
        if (Test-Path $folder) {
            $items = Get-ChildItem -Path $folder
            if ($items.Count -gt 0) {
                Write-Host "`nLocation: $folder" -ForegroundColor White
                $items | Select-Object Name, FullName, CreationTime | Format-Table -AutoSize
                $startupCount += $items.Count
            }
        }
    }
    
    Write-Host "`n(INFO) Total startup items found: $startupCount" -ForegroundColor Cyan
    if($startupCount -gt 15) {
        Write-Host "(WARNING) High number of startup items may slow boot time" -ForegroundColor Yellow
    }
}

function Get-WindowsUpdateStatus {
    Write-Host "`n[+] WINDOWS UPDATE STATUS" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    
    Write-Host "`nChecking for pending updates..." -ForegroundColor Cyan
    try {
        $updateSession = New-Object -ComObject Microsoft.Update.Session
        $updateSearcher = $updateSession.CreateUpdateSearcher()
        $searchResult = $updateSearcher.Search("IsInstalled=0")
        $updates = $searchResult.Updates
        
        if ($updates.Count -gt 0) {
            Write-Host "(INFO) Found $($updates.Count) pending updates" -ForegroundColor Yellow
            $updates | Select-Object -First 10 Title | Format-Table -AutoSize
        } else {
            Write-Host "(OK) System is up to date" -ForegroundColor Green
        }
        
        # Check last update installation time
        $lastUpdate = Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 1
        if ($lastUpdate) {
            Write-Host "`nLast Update Installed:" -ForegroundColor Cyan
            Write-Host "KB         : $($lastUpdate.HotFixID)" -ForegroundColor White
            Write-Host "Installed  : $($lastUpdate.InstalledOn)" -ForegroundColor White
            Write-Host "Description: $($lastUpdate.Description)" -ForegroundColor White
        }
    } catch {
        Write-Host "(ERROR) Unable to check Windows Update status: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Get-HardwareHealth {
    Write-Host "`n[+] TEMPERATURE AND HARDWARE HEALTH" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    
    Write-Host "`nSystem Information:" -ForegroundColor Cyan
    $computerSystem = Get-CimInstance Win32_ComputerSystem
    $bios = Get-CimInstance Win32_BIOS
    
    Write-Host "Manufacturer   : $($computerSystem.Manufacturer)" -ForegroundColor White
    Write-Host "Model          : $($computerSystem.Model)" -ForegroundColor White
    Write-Host "BIOS Version   : $($bios.SMBIOSBIOSVersion)" -ForegroundColor White
    Write-Host "System Type    : $($computerSystem.SystemType)" -ForegroundColor White
    Write-Host "Total Physical : $([math]::Round($computerSystem.TotalPhysicalMemory / 1GB, 2)) GB" -ForegroundColor White
    
    Write-Host "`nPhysical Disk Health:" -ForegroundColor Cyan
    try {
        $physicalDisks = Get-PhysicalDisk
        foreach ($disk in $physicalDisks) {
            Write-Host "`nDisk           : $($disk.FriendlyName)" -ForegroundColor White
            Write-Host "Health Status  : $($disk.HealthStatus)" -ForegroundColor $(if($disk.HealthStatus -eq "Healthy"){"Green"}else{"Red"})
            Write-Host "Operational    : $($disk.OperationalStatus)" -ForegroundColor White
            Write-Host "Size           : $([math]::Round($disk.Size / 1GB, 2)) GB" -ForegroundColor White
            Write-Host "Media Type     : $($disk.MediaType)" -ForegroundColor White
        }
    } catch {
        Write-Host "(INFO) Unable to retrieve physical disk health" -ForegroundColor Yellow
    }
    
    Write-Host "`nTemperature Monitoring:" -ForegroundColor Cyan
    try {
        $temp = Get-CimInstance -Namespace "root/wmi" -ClassName MSAcpi_ThermalZoneTemperature -ErrorAction SilentlyContinue
        if ($temp) {
            foreach ($zone in $temp) {
                $celsius = [math]::Round(($zone.CurrentTemperature / 10) - 273.15, 2)
                Write-Host "Thermal Zone   : $celsius C" -ForegroundColor $(if($celsius -gt 80){"Red"}elseif($celsius -gt 70){"Yellow"}else{"Green"})
            }
        } else {
            Write-Host "(INFO) Temperature monitoring not available via WMI" -ForegroundColor Cyan
        }
    } catch {
        Write-Host "(INFO) Temperature data not accessible on this system" -ForegroundColor Cyan
    }
}

# ==================== NEW ADVANCED FEATURES ====================

function Get-PageFileAnalysis {
    Write-Host "`n[+] PAGEFILE AND VIRTUAL MEMORY ANALYSIS" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    
    $pageFiles = Get-CimInstance Win32_PageFileUsage
    $pageFileSettings = Get-CimInstance Win32_PageFileSetting
    
    if ($pageFiles) {
        foreach ($pf in $pageFiles) {
            Write-Host "`nPageFile       : $($pf.Name)" -ForegroundColor Cyan
            Write-Host "Allocated Size : $($pf.AllocatedBaseSize) MB" -ForegroundColor White
            Write-Host "Current Usage  : $($pf.CurrentUsage) MB" -ForegroundColor White
            Write-Host "Peak Usage     : $($pf.PeakUsage) MB" -ForegroundColor White
            $usagePercent = [math]::Round(($pf.CurrentUsage / $pf.AllocatedBaseSize) * 100, 2)
            Write-Host "Usage Percent  : $usagePercent%" -ForegroundColor $(if($usagePercent -gt 80){"Red"}elseif($usagePercent -gt 60){"Yellow"}else{"Green"})
            
            if($usagePercent -gt 80) {
                Write-Host "(WARNING) PageFile usage is high - consider increasing size" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "(INFO) No PageFile detected (system-managed or disabled)" -ForegroundColor Cyan
    }
    
    # Virtual Memory Stats
    try {
        $commitLimit = (Get-Counter '\Memory\Commit Limit').CounterSamples.CookedValue
        $committedBytes = (Get-Counter '\Memory\Committed Bytes').CounterSamples.CookedValue
        Write-Host "`nVirtual Memory:" -ForegroundColor Cyan
        Write-Host "Commit Limit   : $([math]::Round($commitLimit / 1MB, 2)) MB" -ForegroundColor White
        Write-Host "Committed Bytes: $([math]::Round($committedBytes / 1MB, 2)) MB" -ForegroundColor White
        $commitPercent = [math]::Round(($committedBytes / $commitLimit) * 100, 2)
        Write-Host "Commit Percent : $commitPercent%" -ForegroundColor $(if($commitPercent -gt 90){"Red"}elseif($commitPercent -gt 75){"Yellow"}else{"Green"})
    } catch {}
}

function Get-SystemUptimeAndBoot {
    Write-Host "`n[+] SYSTEM UPTIME AND BOOT PERFORMANCE" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    
    $os = Get-CimInstance Win32_OperatingSystem
    $lastBoot = $os.LastBootUpTime
    $uptime = (Get-Date) - $lastBoot
    
    Write-Host "`nSystem Boot Information:" -ForegroundColor Cyan
    Write-Host "Last Boot Time : $lastBoot" -ForegroundColor White
    Write-Host "Uptime         : $($uptime.Days) days, $($uptime.Hours) hours, $($uptime.Minutes) minutes" -ForegroundColor White
    Write-Host "OS Version     : $($os.Caption) $($os.Version)" -ForegroundColor White
    Write-Host "Architecture   : $($os.OSArchitecture)" -ForegroundColor White
    
    if($uptime.Days -gt 30) {
        Write-Host "(INFO) System uptime exceeds 30 days - consider rebooting" -ForegroundColor Yellow
    }
    
    # Check boot configuration
    try {
        $bootConfig = bcdedit /enum "{current}" | Select-String "timeout", "resumeobject"
        Write-Host "`nBoot Configuration:" -ForegroundColor Cyan
        $bootConfig | ForEach-Object { Write-Host $_ -ForegroundColor White }
    } catch {}
    
    # Get last shutdown reason
    Write-Host "`nLast 5 System Shutdowns/Reboots:" -ForegroundColor Cyan
    $shutdownEvents = Get-EventLog -LogName System -Source "User32" -ErrorAction SilentlyContinue | 
        Where-Object {$_.EventID -eq 1074} | 
        Select-Object -First 5 TimeGenerated, Message
    
    if($shutdownEvents) {
        $shutdownEvents | Format-Table -AutoSize -Wrap
    } else {
        Write-Host "(INFO) No recent shutdown events found" -ForegroundColor Gray
    }
}

function Get-NetworkLatencyTest {
    Write-Host "`n[+] NETWORK LATENCY AND PACKET LOSS TEST" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    
    $targets = @(
        @{Name="Google DNS"; IP="8.8.8.8"},
        @{Name="Cloudflare DNS"; IP="1.1.1.1"},
        @{Name="Local Gateway"; IP=(Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Select-Object -First 1).NextHop}
    )
    
    foreach ($target in $targets) {
        if($target.IP) {
            Write-Host "`nTesting: $($target.Name) ($($target.IP))" -ForegroundColor Cyan
            
            try {
                $pingResults = Test-Connection -ComputerName $target.IP -Count 10 -ErrorAction Stop
                
                $avgLatency = ($pingResults | Measure-Object -Property ResponseTime -Average).Average
                $minLatency = ($pingResults | Measure-Object -Property ResponseTime -Minimum).Minimum
                $maxLatency = ($pingResults | Measure-Object -Property ResponseTime -Maximum).Maximum
                $packetLoss = [math]::Round((1 - ($pingResults.Count / 10)) * 100, 2)
                
                Write-Host "Packets Sent   : 10" -ForegroundColor White
                Write-Host "Packets Recv   : $($pingResults.Count)" -ForegroundColor $(if($pingResults.Count -lt 10){"Red"}else{"Green"})
                Write-Host "Packet Loss    : $packetLoss%" -ForegroundColor $(if($packetLoss -gt 5){"Red"}elseif($packetLoss -gt 1){"Yellow"}else{"Green"})
                Write-Host "Min Latency    : $minLatency ms" -ForegroundColor White
                Write-Host "Avg Latency    : $([math]::Round($avgLatency, 2)) ms" -ForegroundColor $(if($avgLatency -gt 100){"Red"}elseif($avgLatency -gt 50){"Yellow"}else{"Green"})
                Write-Host "Max Latency    : $maxLatency ms" -ForegroundColor White
                
                if($packetLoss -gt 5) {
                    Write-Host "(WARNING) High packet loss detected - check network connectivity" -ForegroundColor Red
                }
                if($avgLatency -gt 100) {
                    Write-Host "(WARNING) High latency detected - network performance may be degraded" -ForegroundColor Yellow
                }
            } catch {
                Write-Host "(ERROR) Unable to ping $($target.IP)" -ForegroundColor Red
            }
        }
    }
}

function Get-AntivirusImpact {
    Write-Host "`n[+] ANTIVIRUS AND WINDOWS DEFENDER IMPACT" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    
    # Windows Defender Status
    try {
        $defenderStatus = Get-MpComputerStatus -ErrorAction SilentlyContinue
        if($defenderStatus) {
            Write-Host "`nWindows Defender Status:" -ForegroundColor Cyan
            Write-Host "Antivirus Enabled      : $($defenderStatus.AntivirusEnabled)" -ForegroundColor $(if($defenderStatus.AntivirusEnabled){"Green"}else{"Red"})
            Write-Host "Real-time Protection   : $($defenderStatus.RealTimeProtectionEnabled)" -ForegroundColor $(if($defenderStatus.RealTimeProtectionEnabled){"Green"}else{"Red"})
            Write-Host "Behavior Monitor       : $($defenderStatus.BehaviorMonitorEnabled)" -ForegroundColor White
            Write-Host "IOAV Protection        : $($defenderStatus.IoavProtectionEnabled)" -ForegroundColor White
            Write-Host "Antivirus Signature Age: $($defenderStatus.AntivirusSignatureAge) days" -ForegroundColor $(if($defenderStatus.AntivirusSignatureAge -gt 7){"Yellow"}else{"Green"})
            Write-Host "Last Quick Scan        : $($defenderStatus.QuickScanEndTime)" -ForegroundColor White
            Write-Host "Last Full Scan         : $($defenderStatus.FullScanEndTime)" -ForegroundColor White
        }
    } catch {
        Write-Host "(INFO) Windows Defender status not available" -ForegroundColor Gray
    }
    
    # Check for third-party AV
    Write-Host "`nInstalled Antivirus Products:" -ForegroundColor Cyan
    try {
        $avProducts = Get-CimInstance -Namespace "root\SecurityCenter2" -ClassName AntiVirusProduct -ErrorAction SilentlyContinue
        if($avProducts) {
            foreach($av in $avProducts) {
                Write-Host "Product: $($av.displayName)" -ForegroundColor White
                Write-Host "State  : $($av.productState)" -ForegroundColor White
            }
        } else {
            Write-Host "(INFO) No third-party antivirus detected" -ForegroundColor Gray
        }
    } catch {
        Write-Host "(INFO) Unable to query antivirus products" -ForegroundColor Gray
    }
    
    # Check AV process resource usage
    Write-Host "`nAntivirus Process Resource Usage:" -ForegroundColor Cyan
    $avProcesses = Get-Process | Where-Object {$_.ProcessName -match "MsMpEng|WinDefend|avp|avgnt|ntrtscan|mbam|ccSvcHst"} -ErrorAction SilentlyContinue
    if($avProcesses) {
        $avProcesses | Select-Object ProcessName, CPU, @{Name="Memory(MB)";Expression={[math]::Round($_.WorkingSet / 1MB, 2)}} | Format-Table -AutoSize
    } else {
        Write-Host "(INFO) No active antivirus processes detected" -ForegroundColor Gray
    }
}

function Get-ProcessHandleAnalysis {
    Write-Host "`n[+] PROCESS HANDLE AND THREAD ANALYSIS" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    
    Write-Host "`nTop 15 Processes by Handle Count:" -ForegroundColor Cyan
    $processes = Get-Process | Sort-Object Handles -Descending | Select-Object -First 15 ProcessName, Handles, Threads, @{Name="Memory(MB)";Expression={[math]::Round($_.WorkingSet / 1MB, 2)}}, Id
    $processes | Format-Table -AutoSize
    
    # Identify potential handle leaks
    $suspiciousProcesses = Get-Process | Where-Object {$_.Handles -gt 10000}
    if($suspiciousProcesses) {
        Write-Host "`n(WARNING) Processes with Excessive Handles (Potential Leak):" -ForegroundColor Yellow
        $suspiciousProcesses | Select-Object ProcessName, Handles, Id | Format-Table -AutoSize
    }
    
    Write-Host "`nTop 15 Processes by Thread Count:" -ForegroundColor Cyan
    Get-Process | Sort-Object Threads -Descending | Select-Object -First 15 ProcessName, Threads, Handles, CPU, Id | Format-Table -AutoSize
    
    # System-wide handle count
    try {
        $totalHandles = (Get-Process | Measure-Object -Property Handles -Sum).Sum
        Write-Host "`nTotal System Handles: $totalHandles" -ForegroundColor White
        if($totalHandles -gt 100000) {
            Write-Host "(INFO) High system handle count - monitor for handle leaks" -ForegroundColor Yellow
        }
    } catch {}
}

function Get-ScheduledTasksAnalysis {
    Write-Host "`n[+] SCHEDULED TASKS ANALYSIS" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    
    Write-Host "`nRecently Run Scheduled Tasks (Last 24h):" -ForegroundColor Cyan
    try {
        $tasks = Get-ScheduledTask | Where-Object {$_.State -ne "Disabled"} | Get-ScheduledTaskInfo | 
            Where-Object {$_.LastRunTime -gt (Get-Date).AddHours(-24)} | 
            Select-Object -First 20 TaskName, LastRunTime, LastTaskResult, NextRunTime
        
        if($tasks) {
            $tasks | Format-Table -AutoSize
        } else {
            Write-Host "(INFO) No tasks run in the last 24 hours" -ForegroundColor Gray
        }
    } catch {
        Write-Host "(INFO) Unable to retrieve scheduled tasks" -ForegroundColor Gray
    }
    
    Write-Host "`nCurrently Running Scheduled Tasks:" -ForegroundColor Cyan
    try {
        $runningTasks = Get-ScheduledTask | Where-Object {$_.State -eq "Running"}
        if($runningTasks) {
            $runningTasks | Select-Object TaskName, State | Format-Table -AutoSize
        } else {
            Write-Host "(OK) No scheduled tasks currently running" -ForegroundColor Green
        }
    } catch {}
    
    Write-Host "`nFailed Scheduled Tasks (Last Result Not Zero):" -ForegroundColor Cyan
    try {
        $failedTasks = Get-ScheduledTask | Get-ScheduledTaskInfo | 
            Where-Object {$_.LastTaskResult -ne 0 -and $_.LastTaskResult -ne 267009} | 
            Select-Object -First 10 TaskName, LastTaskResult, LastRunTime
        
        if($failedTasks) {
            $failedTasks | Format-Table -AutoSize
            Write-Host "(WARNING) Some scheduled tasks have failed - review task history" -ForegroundColor Yellow
        } else {
            Write-Host "(OK) No failed scheduled tasks detected" -ForegroundColor Green
        }
    } catch {}
}

function Get-PowerPlanAnalysis {
    Write-Host "`n[+] POWER PLAN AND BATTERY STATUS" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    
    # Get active power plan
    try {
        $activePlan = powercfg /getactivescheme
        Write-Host "`nActive Power Plan:" -ForegroundColor Cyan
        Write-Host "$activePlan" -ForegroundColor White
        
        # Check if High Performance is active
        if($activePlan -match "Power saver") {
            Write-Host "(WARNING) Power saver mode may reduce system performance" -ForegroundColor Yellow
        } elseif($activePlan -match "High performance") {
            Write-Host "(INFO) High performance mode active - maximum CPU performance" -ForegroundColor Green
        }
    } catch {}
    
    # List all power plans
    Write-Host "`nAvailable Power Plans:" -ForegroundColor Cyan
    powercfg /list
    
    # Battery status (for laptops)
    try {
        $battery = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue
        if($battery) {
            Write-Host "`nBattery Status:" -ForegroundColor Cyan
            Write-Host "Status         : $($battery.Status)" -ForegroundColor White
            Write-Host "Charge Remain  : $($battery.EstimatedChargeRemaining)%" -ForegroundColor $(if($battery.EstimatedChargeRemaining -lt 20){"Red"}elseif($battery.EstimatedChargeRemaining -lt 50){"Yellow"}else{"Green"})
            Write-Host "Battery Health : $($battery.BatteryStatus)" -ForegroundColor White
            Write-Host "Time Remaining : $($battery.EstimatedRunTime) minutes" -ForegroundColor White
        } else {
            Write-Host "`n(INFO) No battery detected (Desktop system)" -ForegroundColor Gray
        }
    } catch {}
    
    # Processor Power Management
    Write-Host "`nProcessor Power Management Settings:" -ForegroundColor Cyan
    try {
        $procPower = powercfg /query SCHEME_CURRENT SUB_PROCESSOR | Select-String "Current AC Power Setting Index", "Current DC Power Setting Index"
        $procPower | ForEach-Object { Write-Host $_ -ForegroundColor White }
    } catch {}
}

function Get-DNSPerformanceTest {
    Write-Host "`n[+] DNS RESOLUTION PERFORMANCE TEST" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    
    # Get current DNS servers
    Write-Host "`nConfigured DNS Servers:" -ForegroundColor Cyan
    $dnsServers = Get-DnsClientServerAddress -AddressFamily IPv4 | Where-Object {$_.ServerAddresses.Count -gt 0}
    $dnsServers | Select-Object InterfaceAlias, ServerAddresses | Format-Table -AutoSize
    
    # Test DNS resolution speed
    $testDomains = @("google.com", "microsoft.com", "github.com", "amazon.com", "cloudflare.com")
    
    Write-Host "`nDNS Resolution Performance Test:" -ForegroundColor Cyan
    Write-Host "Testing 5 popular domains..." -ForegroundColor Gray
    
    $dnsResults = @()
    foreach($domain in $testDomains) {
        try {
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            $result = Resolve-DnsName -Name $domain -ErrorAction Stop
            $sw.Stop()
            
            $dnsResults += [PSCustomObject]@{
                Domain = $domain
                ResolvedIP = $result[0].IPAddress
                TimeMs = $sw.ElapsedMilliseconds
            }
        } catch {
            $dnsResults += [PSCustomObject]@{
                Domain = $domain
                ResolvedIP = "FAILED"
                TimeMs = "-"
            }
        }
    }
    
    $dnsResults | Format-Table -AutoSize
    
    # Calculate average
    $avgTime = ($dnsResults | Where-Object {$_.TimeMs -ne "-"} | Measure-Object -Property TimeMs -Average).Average
    Write-Host "`nAverage DNS Resolution Time: $([math]::Round($avgTime, 2)) ms" -ForegroundColor White
    
    if($avgTime -gt 100) {
        Write-Host "(WARNING) Slow DNS resolution - consider changing DNS servers" -ForegroundColor Yellow
        Write-Host "(SUGGESTION) Try Google DNS (8.8.8.8, 8.8.4.4) or Cloudflare DNS (1.1.1.1, 1.0.0.1)" -ForegroundColor Cyan
    } else {
        Write-Host "(OK) DNS resolution performance is good" -ForegroundColor Green
    }
    
    # DNS cache statistics
    Write-Host "`nDNS Client Cache Statistics:" -ForegroundColor Cyan
    try {
        $dnsCache = Get-DnsClientCache -ErrorAction SilentlyContinue
        if($dnsCache) {
            Write-Host "Cached Entries : $($dnsCache.Count)" -ForegroundColor White
        }
        ipconfig /displaydns | Select-String "Record Name" | Measure-Object | ForEach-Object {
            Write-Host "Total Records  : $($_.Count)" -ForegroundColor White
        }
    } catch {}
}

function Invoke-FullAudit {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "`n╔═══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║                    FULL SYSTEM AUDIT INITIATED                        ║" -ForegroundColor Magenta
    Write-Host "║                    Timestamp: $timestamp                    ║" -ForegroundColor Magenta
    Write-Host "╚═══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
    
    Get-CPUUsage
    Get-MemoryUsage
    Get-DiskPerformance
    Get-NetworkPerformance
    Get-TopProcesses
    Get-ServicesStatus
    Get-EventLogErrors
    Get-StartupPrograms
    Get-WindowsUpdateStatus
    Get-HardwareHealth
    Get-PageFileAnalysis
    Get-SystemUptimeAndBoot
    Get-NetworkLatencyTest
    Get-AntivirusImpact
    Get-ProcessHandleAnalysis
    Get-ScheduledTasksAnalysis
    Get-PowerPlanAnalysis
    Get-DNSPerformanceTest
    
    Write-Host "`n╔═══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║                    FULL AUDIT COMPLETED                               ║" -ForegroundColor Magenta
    Write-Host "╚═══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
}

function Export-AuditReport {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $reportPath = "$env:USERPROFILE\Desktop\SystemAudit_$timestamp.txt"
    
    Write-Host "`n[+] EXPORTING AUDIT REPORT" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    
    Start-Transcript -Path $reportPath -Force
    Invoke-FullAudit
    Stop-Transcript
    
    Write-Host "`n(OK) Report exported successfully to:" -ForegroundColor Green
    Write-Host "    $reportPath" -ForegroundColor Cyan
}

# Main execution loop
do {
    Clear-Host
    Show-Banner
    Show-Menu
    
    $choice = Read-Host "`nSelect an option (0-20)"
    
    switch ($choice) {
        "1"  { Get-CPUUsage }
        "2"  { Get-MemoryUsage }
        "3"  { Get-DiskPerformance }
        "4"  { Get-NetworkPerformance }
        "5"  { Get-TopProcesses }
        "6"  { Get-ServicesStatus }
        "7"  { Get-EventLogErrors }
        "8"  { Get-StartupPrograms }
        "9"  { Get-WindowsUpdateStatus }
        "10" { Get-HardwareHealth }
        "11" { Invoke-FullAudit }
        "12" { Export-AuditReport }
        "13" { Get-PageFileAnalysis }
        "14" { Get-SystemUptimeAndBoot }
        "15" { Get-NetworkLatencyTest }
        "16" { Get-AntivirusImpact }
        "17" { Get-ProcessHandleAnalysis }
        "18" { Get-ScheduledTasksAnalysis }
        "19" { Get-PowerPlanAnalysis }
        "20" { Get-DNSPerformanceTest }
        "0"  { 
            Write-Host "`n(OK) Exiting audit tool. Thank you!" -ForegroundColor Green
            Start-Sleep -Seconds 1
            break 
        }
        default { 
            Write-Host "`n(ERROR) Invalid selection. Please choose 0-20." -ForegroundColor Red 
        }
    }
    
    if ($choice -ne "0") {
        Write-Host "`n" -NoNewline
        Read-Host "Press Enter to return to menu"
    }
    
} while ($choice -ne "0")
