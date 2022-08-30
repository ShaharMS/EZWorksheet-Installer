function createShortcut {
    param ([string]$StartPath, [string]$TargetFile, [string]$ShortcutFile, [string]$IconPath)
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
    $Shortcut.TargetPath = $TargetFile
    $Shortcut.IconLocation = $IconPath
    $Shortcut.WorkingDirectory = $StartPath
    $Shortcut.Save()
}