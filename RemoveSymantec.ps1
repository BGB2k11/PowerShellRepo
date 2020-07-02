$symantec = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "Symantec Endpoint Protection"}

if ($symantec -eq '') {
    Write-Host No Symantec installed
    Exit 0

} else {
    $AppGUID = $symantec.properties["IdentifyingNumber"].value.toString()
    Write-Host $AppGUID
    msiexec.exe /norestart /q/x $AppGUID REMOVE=ALL
    Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "Symantec Endpoint Protection"}
        if ($symantec -eq '') {
            Write-Host Uninstall Completed Reboot Needed
            Exit 0
        
        } else {
            Write-Host Uninstallation Not Succeeded
            Exit 1
        }
}

Set-ExecutionPolicy Unrestricted