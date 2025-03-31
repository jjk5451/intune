try {
    Write-Output "`n--- Starting script at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ---"

    $baseKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey('LocalMachine', 'Registry64')
    $enrollmentsKey = $baseKey.OpenSubKey('SOFTWARE\Microsoft\Enrollments', $true)

    if ($enrollmentsKey) {
        $subKeys = $enrollmentsKey.GetSubKeyNames()
        if ($subKeys.Count -eq 0) {
            Write-Output "No subkeys found under Enrollments."
        } else {
            foreach ($subKey in $subKeys) {
                try {
                    $enrollmentsKey.DeleteSubKeyTree($subKey)
                    Write-Output "Deleted subkey: $subKey"
                } catch {
                    Write-Output "Failed to delete subkey: $subKey - $($_.Exception.Message)"
                }
            }
        }
    } else {
        Write-Output "Registry path 'SOFTWARE\Microsoft\Enrollments' not found."
    }

    Write-Output "`nRunning 'gpupdate /force /wait:0'..."
    Start-Process gpupdate -ArgumentList "/force /wait:0" -NoNewWindow -Wait

} catch {
    Write-Output "SCRIPT FAILURE - $($_.Exception.Message)"
}
