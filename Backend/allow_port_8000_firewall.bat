@echo off
:: Run this file as Administrator (right-click -> Run as administrator)
echo Adding Windows Firewall rule for Legal Sathi backend (TCP port 8000)...
netsh advfirewall firewall add rule name="Legal Sathi API 8000" dir=in action=allow protocol=TCP localport=8000 profile=private,public
if errorlevel 1 (
    echo Failed. Make sure you right-clicked and chose "Run as administrator".
    pause
    exit /b 1
)
echo Done. On your phone Safari open: http://YOUR_LAPTOP_IP:8000/
echo Find IP with: ipconfig  ^(Wi-Fi IPv4^)
pause
