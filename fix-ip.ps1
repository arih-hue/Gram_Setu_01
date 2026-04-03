# Get current IPv4 address
$ip = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Wi-Fi" | Select-Object -ExpandProperty IPAddress)

if (-not $ip) {
    # If Wi-Fi isn't found, try other adapters
    $ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notmatch "127.0.0.1" -and $_.PrefixOrigin -match "Dhcp" } | Select-Object -First 1 -ExpandProperty IPAddress)
}

if ($ip) {
    Write-Host "✅ Detected Current IP: $ip" -ForegroundColor Green
    
    $filePath = "lib/core/constants.dart"
    if (Test-Path $filePath) {
        $content = Get-Content $filePath
        $found = $false
        
        $newContent = $content | ForEach-Object {
            if ($_ -match "static const String kBaseUrl") {
                $found = $true
                return "  static const String kBaseUrl = 'http://$($ip):3000';"
            }
            return $_
        }
        
        if ($found) {
            $newContent | Set-Content $filePath
            Write-Host "✅ Updated $filePath with the new IP." -ForegroundColor Green
        } else {
            Write-Host "❌ Could not find kBaseUrl in $filePath" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Could not find file: $filePath" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Could not detect local IP. Check your network connection." -ForegroundColor Red
}

Write-Host "`nSteps for next time:"
Write-Host "1. Run your backend: cd backend; npm start"
Write-Host "2. Run this script: .\fix-ip.ps1"
Write-Host "3. Restart your Flutter app."
