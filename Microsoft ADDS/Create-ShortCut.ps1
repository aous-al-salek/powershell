<#
    .SYNOPSIS
    Creates shortcut.
    
    .DESCRIPTION
    Creates shortcut and takes two string parameters on invokation.
    The first parameters is the the path to the source executable file.
    The second parameter is the path to the destination link file.

    .INPUTS
    The first parameters is the the path to the source executable file.
    The second parameter is the path to the destination link file.
    
    .OUTPUTS
    Outputs a link file of an executable file.
    
    .EXAMPLE
    PS> Create-ShortCut "C:\Program Files (x86)\example\example.exe" "$Home\Desktop\example.lnk"
#>

param([string]$SourceExe, [string]$DestinationPath)

$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($DestinationPath)
$Shortcut.TargetPath = $SourceExe
$Shortcut.Save()
