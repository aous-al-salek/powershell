<#
    .SYNOPSIS
    Setup NTP Server.
    
    .DESCRIPTION
    Setup an NTP server in a Windows environment using an interactive GUI.
    Takes no inputs and produces no outputs.

    .INPUTS
    None.
    
    .OUTPUTS
    None.
    
    .EXAMPLE
    PS> Create-NTPServer
#>

########################################## RELEVANT DOCUMENTATION #################################################
# Relevant documentation                                                                                          #
# https://docs.microsoft.com/en-us/troubleshoot/windows-server/identity/configure-authoritative-time-server       #
# https://docs.microsoft.com/en-us/troubleshoot/windows-server/identity/configure-w32ime-against-huge-time-offset #
###################################################################################################################

Function Get-Choice ([string]$Text1, [string]$Text2, [string]$Option1, [string]$Option2) {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'NTP Server'
    $form.Size = New-Object System.Drawing.Size(700,450)
    $form.StartPosition = 'CenterScreen'
    $form.MaximizeBox = $false
    $form.MinimizeBox = $true
    $form.MaximumSize = '700, 450'
    $form.MinimumSize = '700, 450'
    $form.BackColor = 'White' #'LightGray' #'Black' #'Gray'
    $form.FormBorderStyle = 'FixedSingle'#'SizableToolWindow' #'FixedToolWindow' #'Sizable' #'None' #'FixedDialog' #'Fixed3D' #'FixedSingle'
    
    $Button1 = New-Object System.Windows.Forms.Button
    $Button1.Location = New-Object System.Drawing.Point(450,365)
    $Button1.Size = New-Object System.Drawing.Size(75,23)
    $Button1.Text = $Option1
    $Button1.FlatStyle = 'Flat' #'System' #'Standard' #'Popup'
    $Button1.BackColor = 'LightGreen'
    $Button1.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $Button1
    $form.Controls.Add($Button1)
    
    $Button2 = New-Object System.Windows.Forms.Button
    $Button2.Location = New-Object System.Drawing.Point(550,365)
    $Button2.Size = New-Object System.Drawing.Size(75,23)
    $Button2.Text = $Option2
    $Button2.FlatStyle = 'Flat' #'System' #'Standard' #'Popup'
    $Button2.BackColor = 'Red'
    $Button2.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $Button2
    $form.Controls.Add($Button2)

    $label1 = New-Object System.Windows.Forms.Label
    $label1.Location = New-Object System.Drawing.Point(50,50)
    $label1.Size = New-Object System.Drawing.Size(550,50)
    $label1.Font = New-Object System.Drawing.Font('Arial', 12, [Drawing.FontStyle]::Bold)
    $label1.Text = $Text1
    #$label1.Dock = 'Fill'
    #$label1.Margin = 50
    $form.Controls.Add($label1)
    
    $label2 = New-Object System.Windows.Forms.Label
    $label2.Location = New-Object System.Drawing.Point(50,150)
    $label2.Size = New-Object System.Drawing.Size(550,250)
    $label2.Font = New-Object System.Drawing.Font('TimesNewRoman', 10)
    $label2.Text = $Text2
    $form.Controls.Add($label2)
    
    $form.Topmost = $true

    $result = $form.ShowDialog()
    Return $result
}

Function Finish-Setup ([string]$Text1, [string]$Text2, [string]$Option) {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'NTP Server'
    $form.Size = New-Object System.Drawing.Size(700,450)
    $form.StartPosition = 'CenterScreen'
    $form.MaximizeBox = $false
    $form.MinimizeBox = $true
    $form.MaximumSize = '700, 450'
    $form.MinimumSize = '700, 450'
    $form.BackColor = 'Green' #'White' #'LightGray' #'Black' #'Gray'
    $form.FormBorderStyle = 'FixedSingle'#'SizableToolWindow' #'FixedToolWindow' #'Sizable' #'None' #'FixedDialog' #'Fixed3D' #'FixedSingle'
    
    $Button = New-Object System.Windows.Forms.Button
    $Button.Location = New-Object System.Drawing.Point(550,365)
    $Button.Size = New-Object System.Drawing.Size(75,23)
    $Button.Text = $Option
    $Button.FlatStyle = 'Flat' #'System' #'Standard' #'Popup'
    $Button.BackColor = 'White'
    $Button.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $Button
    $form.Controls.Add($Button)

    $label1 = New-Object System.Windows.Forms.Label
    $label1.Location = New-Object System.Drawing.Point(50,50)
    $label1.Size = New-Object System.Drawing.Size(550,50)
    $label1.Font = New-Object System.Drawing.Font('Arial', 12, [Drawing.FontStyle]::Bold)
    $label1.Text = $Text1
    #$label1.Dock = 'Fill'
    #$label1.Margin = 50
    $form.Controls.Add($label1)
    
    $label2 = New-Object System.Windows.Forms.Label
    $label2.Location = New-Object System.Drawing.Point(50,150)
    $label2.Size = New-Object System.Drawing.Size(550,250)
    $label2.Font = New-Object System.Drawing.Font('TimesNewRoman', 10)
    $label2.Text = $Text2
    $form.Controls.Add($label2)
    
    $form.Topmost = $true

    $result = $form.ShowDialog()
    Return $result
}

Function Failed-Setup ([string]$Text1, [string]$Text2, [string]$Option) {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'NTP Server'
    $form.Size = New-Object System.Drawing.Size(700,450)
    $form.StartPosition = 'CenterScreen'
    $form.MaximizeBox = $false
    $form.MinimizeBox = $true
    $form.MaximumSize = '700, 450'
    $form.MinimumSize = '700, 450'
    $form.BackColor = 'Gray' #'White' #'LightGray' #'Black' #'Gray'
    $form.FormBorderStyle = 'FixedSingle'#'SizableToolWindow' #'FixedToolWindow' #'Sizable' #'None' #'FixedDialog' #'Fixed3D' #'FixedSingle'
    
    $Button = New-Object System.Windows.Forms.Button
    $Button.Location = New-Object System.Drawing.Point(550,365)
    $Button.Size = New-Object System.Drawing.Size(75,23)
    $Button.Text = $Option
    $Button.FlatStyle = 'Flat' #'System' #'Standard' #'Popup'
    $Button.BackColor = 'White'
    $Button.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $Button
    $form.Controls.Add($Button)

    $label1 = New-Object System.Windows.Forms.Label
    $label1.Location = New-Object System.Drawing.Point(50,50)
    $label1.Size = New-Object System.Drawing.Size(550,50)
    $label1.Font = New-Object System.Drawing.Font('Arial', 12, [Drawing.FontStyle]::Bold)
    $label1.Text = $Text1
    #$label1.Dock = 'Fill'
    #$label1.Margin = 50
    $form.Controls.Add($label1)
    
    $label2 = New-Object System.Windows.Forms.Label
    $label2.Location = New-Object System.Drawing.Point(50,150)
    $label2.Size = New-Object System.Drawing.Size(550,250)
    $label2.Font = New-Object System.Drawing.Font('TimesNewRoman', 10)
    $label2.Text = $Text2
    $form.Controls.Add($label2)
    
    $form.Topmost = $true

    $result = $form.ShowDialog()
    Return $result
}

Function Encountered-Error ([string]$Text1, [string]$Text2, [string]$Option) {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'NTP Server'
    $form.Size = New-Object System.Drawing.Size(700,450)
    $form.StartPosition = 'CenterScreen'
    $form.MaximizeBox = $false
    $form.MinimizeBox = $true
    $form.MaximumSize = '700, 450'
    $form.MinimumSize = '700, 450'
    $form.BackColor = 'Red' #'White' #'LightGray' #'Black' #'Gray'
    $form.FormBorderStyle = 'FixedSingle'#'SizableToolWindow' #'FixedToolWindow' #'Sizable' #'None' #'FixedDialog' #'Fixed3D' #'FixedSingle'
    
    $Button = New-Object System.Windows.Forms.Button
    $Button.Location = New-Object System.Drawing.Point(550,365)
    $Button.Size = New-Object System.Drawing.Size(75,23)
    $Button.Text = $Option
    $Button.FlatStyle = 'Flat' #'System' #'Standard' #'Popup'
    $Button.BackColor = 'Yellow'
    $Button.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $Button
    $form.Controls.Add($Button)

    $label1 = New-Object System.Windows.Forms.Label
    $label1.Location = New-Object System.Drawing.Point(50,50)
    $label1.Size = New-Object System.Drawing.Size(550,50)
    $label1.Font = New-Object System.Drawing.Font('Arial', 12, [Drawing.FontStyle]::Bold)
    $label1.Text = $Text1
    #$label1.Dock = 'Fill'
    #$label1.Margin = 50
    $form.Controls.Add($label1)
    
    $label2 = New-Object System.Windows.Forms.Label
    $label2.Location = New-Object System.Drawing.Point(50,150)
    $label2.Size = New-Object System.Drawing.Size(550,250)
    $label2.Font = New-Object System.Drawing.Font('TimesNewRoman', 10)
    $label2.Text = $Text2
    $form.Controls.Add($label2)
    
    $form.Topmost = $true

    $result = $form.ShowDialog()
    Return $result
}

$decision = Get-Choice 'NTP Server' 'This program creates an NTP server in a Microsoft Windows environment and synhronizes its clock with the following NTP servers:

time.windows.com
pool.ntp.org
' 'Next' 'Cancel'
if ($decision -like 'OK') {
    Write-Host 'Next' -BackgroundColor Green -ForegroundColor White
} else {
    Write-Host 'Cancel' -BackgroundColor Red -ForegroundColor White
    Return
}

$decision = Get-Choice 'Time Service' 'Running this program will cause the "w32Time" service to be temporarly stopped.

Do you want to proceed?' 'Yes' 'No'
if ($decision -like 'OK') {
    Write-Host 'Yes' -BackgroundColor Green -ForegroundColor White
} else {
    Write-Host 'No' -BackgroundColor Red -ForegroundColor White
    Return
}

$decision = Get-Choice 'Windows Registry' 'This program will change the value of the following registry key from "time.windows.com,0x8" to "time.windows.com,0x8 pool.ntp.org,0x8":

HKLM:\SYSTEM\CurrentControlSet\Services\w32time\TimeProviders\Parameters\NtpServer

Do you want to proceed?' 'Yes' 'No'
if ($decision -like 'OK') {
    Write-Host 'Yes' -BackgroundColor Green -ForegroundColor White
} else {
    Write-Host 'No' -BackgroundColor Red -ForegroundColor White
    Return
}

$decision = Get-Choice 'Windows Registry' 'This program will change the value of the following registry key from "0xffffffff" to "0x1C20":

HKLM:\SYSTEM\CurrentControlSet\Services\w32time\Config\MaxPosPhaseCorrection

Do you want to proceed?' 'Yes' 'No'
if ($decision -like 'OK') {
    Write-Host 'Yes' -BackgroundColor Green -ForegroundColor White
} else {
    Write-Host 'No' -BackgroundColor Red -ForegroundColor White
    Return
}

$decision = Get-Choice 'Windows Registry' 'This program will change the value of the following registry key from "0xffffffff" to "0x1C20":

HKLM:\SYSTEM\CurrentControlSet\Services\w32time\Config\MaxNegPhaseCorrection

Do you want to proceed?' 'Yes' 'No'
if ($decision -like 'OK') {
    Write-Host 'Yes' -BackgroundColor Green -ForegroundColor White
} else {
    Write-Host 'No' -BackgroundColor Red -ForegroundColor White
    Return
}

$decision = Get-Choice 'Windows Registry' 'This program will change the value of the following registry key from "a" to "5":

HKLM:\SYSTEM\CurrentControlSet\Services\w32time\Config\AnnounceFlags

Do you want to proceed?' 'Yes' 'No'
if ($decision -like 'OK') {
    Write-Host 'Yes' -BackgroundColor Green -ForegroundColor White
} else {
    Write-Host 'No' -BackgroundColor Red -ForegroundColor White
    Return
}

$decision = Get-Choice 'Windows Registry' 'This program will change the value of the following registry key from "0" to "1":

HKLM:\SYSTEM\CurrentControlSet\Services\w32time\TimeProviders\NtpServer\Enabled

Do you want to proceed?' 'Yes' 'No'
if ($decision -like 'OK') {
    Write-Host 'Yes' -BackgroundColor Green -ForegroundColor White
} else {
    Write-Host 'No' -BackgroundColor Red -ForegroundColor White
    Return
}

$decision = Get-Choice 'Windows Firewall' 'This program will create an inbound firewall rule called "NTP Server" to allow the time service "w32Time" to listen on UDP port 123.

Do you want to proceed?' 'Yes' 'No'
if ($decision -like 'OK') {
    Write-Host 'Yes' -BackgroundColor Green -ForegroundColor White
} else {
    Write-Host 'No' -BackgroundColor Red -ForegroundColor White
    Return
}

# Stop the time service.
Stop-Service w32Time

# Change the value of registry key in order to sync time with external time servers.
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\services\W32Time\Parameters" -Name "NtpServer" -Value "time.windows.com,0x8 pool.ntp.org,0x8"

# Change the value of registry key in order to limit accepted time updates to upstream servers that deviate no more than 2 hourse.
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\services\W32Time\Config" -Name "MaxPosPhaseCorrection" -Value 0x1C20

# Change the value of registry key in order to limit accepted time updates to upstream servers that deviate no more than 2 hourse.
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\services\W32Time\Config" -Name "MaxNegPhaseCorrection" -Value 0x1C20

# Change the value of registry key in order to allow the time service to make announcements in the correct mode.
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\services\W32Time\Config" -Name "AnnounceFlags" -Value 5

# Change the value of registry key in order to allow the server to respond to NTP calient requests.
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\w32time\TimeProviders\NtpServer' -Name 'Enabled' -Value 1

# Open UDP port 123 to allow the time service to listen for NTP client requests.
New-NetFirewallRule -DisplayName 'NTP Server' -Direction Inbound -Action Allow -LocalPort 123 -Protocol UDP -Enabled True -Service w32Time -Profile Any

Try {
    ## Start the time service.
    Start-Service w32Time -ErrorAction Stop
} Catch {
    $decision = Get-Choice 'Fatal Error!' 'Encounterd an error while trying to start the w32time service.
For more information check the minimized terminal window.
    
Warning: some changes were applied to the system!
Do you want to retrieve system changes to default values?' 'Yes' 'No'
    if ($decision -like 'OK') {
        Write-Host 'Yes' -BackgroundColor Green -ForegroundColor White
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\services\W32Time\Parameters" -Name "NtpServer" -Value "time.windows.com,0x8"
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\services\W32Time\Config" -Name "MaxPosPhaseCorrection" -Value 0xffffffff
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\services\W32Time\Config" -Name "MaxNegPhaseCorrection" -Value 0xffffffff
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\services\W32Time\Config" -Name "AnnounceFlags" -Value a
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\w32time\TimeProviders\NtpServer' -Name 'Enabled' -Value 0
        Remove-NetFirewallRule -DisplayName 'NTP Server'
        Try {
            ## Start the time service.
            Start-Service w32Time -ErrorAction Stop
            $decision = Failed-Setup 'NTP Server' 'Setup failed!
For more information check the minimized terminal window.

Note: all system changes were retrieved to default values and the w32time service is running.' 'Close'
            Write-Host 'Finish' -BackgroundColor White -ForegroundColor Black
            Exit
        } Catch {
            $decision = Encountered-Error 'Fatal Error!' 'Encounterd an error while trying to start the w32time service.
For more information check the minimized terminal window.

Note: all system changes were retrieved to default values.' 'Close'
            Write-Host 'Error!' -BackgroundColor Red -ForegroundColor White
            Exit
        }
    } else {
        Write-Host 'No' -BackgroundColor Red -ForegroundColor White
        Exit
    }
}

w32tm /config /update
net stop w32time
net start w32time
w32tm /resync

$decision = Finish-Setup 'NTP Server' 'Setup is done!' 'Finish'
Write-Host 'Finish' -BackgroundColor White -ForegroundColor Black
Exit