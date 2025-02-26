# Chặn Task Manager
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableTaskMgr" -Value 1 -PropertyType DWORD -Force | Out-Null

# Nhập dung lượng RAM của bạn
$totalRAM = Read-Host "Nhập dung lượng RAM của bạn (MB)"
$startTime = Get-Date
$endTime = $startTime.AddSeconds(120)

Write-Host "💀 Windows sẽ cố gắng lấp đầy RAM của bạn trong 120 giây... Bạn chỉ có thể dùng CMD để ngăn chặn!" -ForegroundColor Red

# Tăng mức độ tiêu hao RAM
$ramUsageStep = 10  # Bắt đầu với 10MB
$processList = @()

# Chạy vòng lặp kiểm tra RAM và tiêu hao RAM
while ($true) {
    $currentTime = Get-Date
    $freeRAM = [math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1024, 2)

    if ($currentTime -ge $endTime) {
        Write-Host "🎉 Bạn đã sống sót 120 giây! Bạn thắng!" -ForegroundColor Green
        break
    }

    if ($freeRAM -le 50) {  # Nếu RAM còn dưới 50MB → Thua!
        Write-Host "💀 RAM đã bị đầy! Windows thắng!" -ForegroundColor Red
        Stop-Process -Id $processList -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 3
        Stop-Process -Name explorer -Force
        Start-Sleep -Seconds 5
        Stop-Process -Name powershell -Force
        Start-Sleep -Seconds 2
        shutdown /s /t 5  # Tắt máy sau 5 giây
        break
    }

    # Tạo tiến trình tiêu hao RAM
    try {
        $process = Start-Process -FilePath "notepad.exe" -PassThru  # Mở Notepad để chiếm RAM
        $processList += $process.Id
        Start-Sleep -Milliseconds 200
        $ramUsageStep += 5  # Tăng dần tiêu hao RAM
    }
    catch {
        Write-Host "💀 Windows đã khiến bạn bị đầy RAM!" -ForegroundColor Red
        shutdown /s /t 5  # Tắt máy sau 5 giây
        break
    }

    Write-Host "⏳ Đang chạy... Còn $([math]::Round(($endTime - $currentTime).TotalSeconds)) giây - RAM trống: $freeRAM MB" -ForegroundColor Yellow
    Start-Sleep -Seconds 1
}

# Bật lại Task Manager sau khi kết thúc
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableTaskMgr" -ErrorAction SilentlyContinue | Out-Null
Write-Host "🔓 Task Manager đã được bật lại!" -ForegroundColor Green
