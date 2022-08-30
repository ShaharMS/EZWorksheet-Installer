function createShortcut {
    param ([string]$TargetFile, [string]$ShortcutFile)
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
    $Shortcut.TargetPath = $TargetFile
    $Shortcut.Save()
}
    
createShortcut "WILL_INSERT_PATH_HERE" "WILL_INSERT_PATH_HERE.lnk"