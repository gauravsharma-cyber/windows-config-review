@echo off
setlocal enabledelayedexpansion

:: Set file path for report output
set outputDir=%SystemDrive%\CIS_Endpoint_Report
set reportFile=%outputDir%\endpoint.csv

:: Create report directory if it does not exist
if not exist "%outputDir%" mkdir "%outputDir%"

:: Add headers to the CSV file if it doesn't exist
if not exist %reportFile% (
    echo Test,Result,CommandOutput,hostname,Command > %reportFile%
)

:: Checking for Administrator Privileges
set commandOutput=
for /f "tokens=*" %%i in ('whoami /groups') do set commandOutput=%%i

:: Get the hostname address
set hostname=hostname
for /f "delims=" %%i in ('hostname') do set hostname=%%i
set InstalledSoftwareOutput=powershell Get-Package -ProviderName Programs
for /f "delims=" %%i in ('powershell Get-Package -ProviderName Programs') do (
    set InstalledSoftwareOutput=!InstalledSoftwareOutput!%%i,
)
:: Output for Installed Software Check in a new row
echo "InstalledSoftware", "NA", !InstalledSoftwareOutput!, %hostname%, "Get-Package -ProviderName Programs" >> %reportFile%

set localgroup=net localgroup
for /f "delims=" %%i in ('net localgroup') do (
    set localgroup=!localgroup!%%i,
)
:: Output for lookup Check in a new row
echo "Net Localgroup", "NA", !localgroup!, %hostname%, "net localgroup" >> %reportFile%


set netaccountsOutput=net accounts
for /f "delims=" %%i in ('net accounts') do (
    set netaccountsOutput=!netaccountsOutput!%%i,
)
:: Output for lookup Check in a new row
echo "Net Accounts", "NA", !netaccountsOutput!, %hostname%, "net accounts" >> %reportFile%

set gpresultOutput=gpresult
for /f "delims=" %%i in ('gpresult /r') do (
    set gpresultOutput=!gpresultOutput!%%i,
)
:: Output for lookup Check in a new row
echo "Group Policy", "NA", !gpresultOutput!, %hostname%, "gpresult /r" >> %reportFile%

set gpresultOutput=gpresult
for /f "delims=" %%i in ('gpresult /r') do (
    set gpresultOutput=!gpresultOutput!%%i,
)
:: Output for lookup Check in a new row
echo "Group Policy", "NA", !gpresultOutput!, %hostname%, "gpresult /r" >> %reportFile%

set BluetoothOutput=sc query BTAGService
for /f "delims=" %%i in ('sc query BTAGService') do (
    set BluetoothOutput=!BluetoothOutput!%%i,
)
:: Output for lookup Check in a new row
echo "Bluetooth", "NA", !BluetoothOutput!, %hostname%, "sc query BTAGService" >> %reportFile%


:: Output for Administrator Privileges check
set command=whoami /groups
whoami /groups | findstr /i "S-1-5-32-544" >nul
if %errorlevel% equ 0 (
    set result=PASS
) else (
    set result=FAIL
)
echo Administrator Privileges Enabled, %result%, "%commandOutput%", %hostname%, "%command%" >> %reportFile%

:: Checking Windows Defender Antivirus status
set defenderStatus=Not Found
set defenderCommand=sc query WinDefend
sc query WinDefend | findstr /i "RUNNING" > nul
if %errorlevel% equ 0 (
    set defenderStatus=Enabled
    set result=PASS
) else (
    set defenderStatus=Disabled
    set result=FAIL
)
:: Output for Windows Defender check in a new row
echo Windows Defender Status, %result%, %defenderStatus%, %hostname%, "%defenderCommand%" >> %reportFile%

:: Checking if User Account Control (UAC) is enabled
set uacStatus=Not Found
set uacCommand=reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA
:: Output CommandOutput for UAC check
for /f "tokens=3" %%a in ('%uacCommand% 2^>nul') do set uacStatus=%%a

if "%uacStatus%"=="0x1" (
    set result=PASS
) else (
    set result=FAIL
)
set uacCommandOutput=%uacStatus%
:: Output for UAC check in a new row
echo User Account Control (UAC) enabled, %result%, "%uacCommandOutput%", %hostname%, "%uacCommand%" >> %reportFile%


:: Checking if Secure Boot is enabled
set secureBootStatus=Not Found
set secureBootCommand=powershell Confirm-SecureBootUEFI
for /f "tokens=*" %%b in ('%secureBootCommand%') do set secureBootStatus=%%b

:: Check Secure Boot status
if "%secureBootStatus%"=="True" (
    set result=PASS
) else (
    set result=FAIL
)

:: Output for Secure Boot check in a new row
echo Secure Boot enabled, %result%, "%secureBootStatus%", %hostname%, "%secureBootCommand%" >> %reportFile%

:: Checking if Remote Desktop is disabled
set rdpStatus=Not Found
set rdpCommand=reg query "HKLM\System\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections
for /f "tokens=3" %%c in ('%rdpCommand% 2^>nul') do set rdpStatus=%%c

:: Output CommandOutput for Remote Desktop check
set rdpCommandOutput=%rdpStatus%

if "%rdpStatus%"=="0x1" (
    set result=PASS
) else (
    set result=FAIL
)

:: Output for Remote Desktop check in a new row
echo Remote Desktop enabled, %result%, "%rdpCommandOutput%", %hostname%, "%rdpCommand%" >> %reportFile%


:: Checking if Windows Firewall is enabled
set firewallStatus=Not Found
set firewallCommand=netsh advfirewall show allprofiles
for /f "tokens=*" %%f in ('%firewallCommand% ^| findstr /i "State"') do set firewallStatus=%%f

:: Output CommandOutput for Windows Firewall check
set firewallCommandOutput=%firewallStatus%

if "%firewallStatus%"=="State                                 ON" (
    set result=PASS
) else (
    set result=FAIL
)

:: Output for Windows Firewall check in a new row
echo Windows Firewall, %result%, "%firewallCommandOutput%", %hostname%, "%firewallCommand%" >> %reportFile%

:: Checking if Windows Update is enabled
set updateStatus=Not Found
set updateCommand=sc query wuauserv
sc query wuauserv | findstr /i "RUNNING" > nul
if %errorlevel% equ 0 (
    set updateStatus=RUNNING
    set result=PASS
) else (
    set updateStatus=STOPPED
    set result=FAIL
)


:: Output for Windows Update check in a new row
echo Windows Update, %result%, "%updateStatus%", %hostname%, "%updateCommand%" >> %reportFile%

:: Checking if SMBv1 is disabled
set smbStatus=Not Found
set smbCommand=reg query "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v SMB1
for /f "tokens=3" %%c in ('%smbCommand% 2^>nul') do set smbStatus=%%c

:: Output CommandOutput for SMBv1 check
set smbCommandOutput=%smbStatus%

if "%smbStatus%"=="0x0" (
    set result=PASS
) else (
    set result=FAIL
)

:: Output for SMBv1 check in a new row
echo SMBv1, %result%, "%smbCommandOutput%", %hostname%, "%smbCommand%" >> %reportFile%

:: Checking if SMBv2 is disabled
set smb2Status=Not Found
set smb2Command=powershell Get-SmbServerConfiguration
for /f "tokens=3" %%c in ('%smb2Command% ^| findstr -i EnableSMB2Protocol') do set smb2Status=%%c

:: Output CommandOutput for SMBv2 check
set smb2CommandOutput=%smb2Status%

if "%smb2Status%"=="True" (
    set result=FAIL
) else (
    set result=PASS
)

:: Output for SMBv2 check in a new row
echo SMBv2, %result%, "%smb2CommandOutput%", %hostname%, "%smb2Command%" >> %reportFile%

:: Checking if "User Account Control: Detect application installations" is enabled
set uacInstallerDetectionStatus=Not Found
set uacCommand=reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableInstallerDetection
for /f "tokens=3" %%c in ('%uacCommand% 2^>nul') do set uacInstallerDetectionStatus=%%c

:: Output CommandOutput for UAC Detect Installation check
set uacCommandOutput=%uacInstallerDetectionStatus%

if "%uacInstallerDetectionStatus%"=="0x1" (
    set result=PASS
) else (
    set result=FAIL
)

:: Output for UAC "Detect application installations" check in a new row
echo "UAC: Detect application installations", %result%, "%uacCommandOutput%", %hostname%, "%uacCommand%" >> %reportFile%


:: Checking if MinimumPasswordLength is set
set MinimumPasswordLength=Not Found
set MinimumPasswordLengthCommand=secedit /export /cfg "%temp%\secpol.cfg" /areas SECURITYPOLICY
secedit /export /cfg "%temp%\secpol.cfg" /areas SECURITYPOLICY
for /f "tokens=3" %%c in ('type %temp%\secpol.cfg ^| findstr /i "MinimumPasswordLength"') do set MinimumPasswordLength=%%c

:: Output CommandOutput for MinimumPasswordLength check
set MinimumPasswordLengthCommandOutput=%MinimumPasswordLength%

if "%MinimumPasswordLength%"=="12" (
    set result=PASS
) else (
    set result=FAIL
)

:: Output for Minimum Password Check in a new row
echo "MinimumPasswordLength", %result%, "%MinimumPasswordLengthCommandOutput%", %hostname%, "%MinimumPasswordLengthCommand%" >> %reportFile%
del "%temp%\secpol.cfg" 

:: Checking if AllowAdministratorLockout is set
set AllowAdministratorLockout=Not Found
set AllowAdministratorLockoutCommand=secedit /export /cfg "%temp%\secpol.cfg" /areas SECURITYPOLICY
secedit /export /cfg "%temp%\secpol.cfg" /areas SECURITYPOLICY
for /f "tokens=3" %%c in ('type %temp%\secpol.cfg ^| findstr /i "AllowAdministratorLockout"') do set AllowAdministratorLockout=%%c

:: Output CommandOutput for AllowAdministratorLockout check
set AllowAdministratorLockoutCommandOutput=%AllowAdministratorLockout%

if "%AllowAdministratorLockout%"=="1" (
    set result=PASS
) else (
    set result=FAIL
)

:: Output for UAC AllowAdministratorLockout check in a new row
echo "AllowAdministratorLockout", %result%, "%AllowAdministratorLockoutCommandOutput%", %hostname%, "%AllowAdministratorLockoutCommand%" >> %reportFile%
del "%temp%\secpol.cfg" 

:: Checking if LockoutBadCount is set
set LockoutBadCount=Not Found
set LockoutBadCountCommand=secedit /export /cfg "%temp%\secpol.cfg" /areas SECURITYPOLICY
secedit /export /cfg "%temp%\secpol.cfg" /areas SECURITYPOLICY
for /f "tokens=3" %%c in ('type %temp%\secpol.cfg ^| findstr /i "LockoutBadCount"') do set LockoutBadCount=%%c

:: Output CommandOutput for LockoutBadCount check
set LockoutBadCountCommandOutput=%LockoutBadCount%

if "%LockoutBadCount%"=="5" (
    set result=PASS
) else (
    set result=FAIL
)

:: Output for UAC LockoutBadCount check in a new row
echo "LockoutBadCount", %result%, "%LockoutBadCountCommandOutput%", %hostname%, "%LockoutBadCountCommand%" >> %reportFile%
del "%temp%\secpol.cfg" 

:: Checking if EnableGuestAccount is set
set EnableGuestAccount=Not Found
set EnableGuestAccountCommand=secedit /export /cfg "%temp%\secpol.cfg" /areas SECURITYPOLICY
secedit /export /cfg "%temp%\secpol.cfg" /areas SECURITYPOLICY
for /f "tokens=3" %%c in ('type %temp%\secpol.cfg ^| findstr /i "EnableGuestAccount"') do set EnableGuestAccount=%%c

:: Output CommandOutput for EnableGuestAccount check
set EnableGuestAccountCommandOutput=%EnableGuestAccount%

if "%EnableGuestAccount%"=="0" (
    set result=PASS
) else (
    set result=FAIL
)

:: Output for UAC EnableGuestAccount check in a new row
echo "EnableGuestAccount", %result%, "%EnableGuestAccountCommandOutput%", %hostname%, "%EnableGuestAccountCommand%" >> %reportFile%
del "%temp%\secpol.cfg"


:: Copy report to a network shared folder for AD Group access (update path as needed)
copy "%reportFile%" \\192.168.1.37\c$\test /Z /Y
rmdir /s /q "%outputDir%"



endlocal
