 # Load WinSCP .NET assembly
Add-Type -Path "C:\Program Files (x86)\WinSCP\WinSCPnet.dll"
 
# Session.FileTransferred event handler
 
function FileTransferred
{
    param($e)
 
    if ($e.Error -eq $Null)
    {
        Write-Host "Upload of $($e.FileName) succeeded"
    }
    else
    {
        Write-Host "Upload of $($e.FileName) failed: $($e.Error)"
    }
 
    if ($e.Chmod -ne $Null)
    {
        if ($e.Chmod.Error -eq $Null)
        {
            Write-Host "Permissions of $($e.Chmod.FileName) set to $($e.Chmod.FilePermissions)"
        }
        else
        {
            Write-Host "Setting permissions of $($e.Chmod.FileName) failed: $($e.Chmod.Error)"
        }
 
    }
    else
    {
        Write-Host "Permissions of $($e.Destination) kept with their defaults"
    }
 
    if ($e.Touch -ne $Null)
    {
        if ($e.Touch.Error -eq $Null)
        {
            Write-Host "Timestamp of $($e.Touch.FileName) set to $($e.Touch.LastWriteTime)"
        }
        else
        {
            Write-Host "Setting timestamp of $($e.Touch.FileName) failed: $($e.Touch.Error)"
        }
 
    }
    else
    {
        # This should never happen during "local to remote" synchronization
        Write-Host "Timestamp of $($e.Destination) kept with its default (current time)"
    }
}
 
# Main script
 
try
{
    $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
    Protocol = [WinSCP.Protocol]::Sftp
    HostName = "hostname"
    UserName = "USername"
    Password = "Password"
    SshHostKeyFingerprint = "sshkey"
    }
 
    $session = New-Object WinSCP.Session

    try
    {
        # Will continuously report progress of synchronization
        $session.add_FileTransferred( { FileTransferred($_) } )
        
        # Connect
        $session.Open($sessionOptions)
 
        # Synchronize files
        $synchronizationResult = $session.SynchronizeDirectories(
            [WinSCP.SynchronizationMode]::Local, "D:\SDP\sdppc\import\sdw_employee\", "/", $False)

        foreach ($download in $synchronizationResult.Downloads)
        {
            # Success or error?
            if ($download.Error -eq $Null)
            {
                Write-Host "Download of $($download.FileName) succeeded, removing from source"
                # Download succeeded, remove file from source
                $filename = [WinSCP.RemotePath]::EscapeFileMask($download.FileName)
                $removalResult = $session.RemoveFiles($filename)
 
                if ($removalResult.IsSuccess)
                {
                    Write-Host "Removing of file $($download.FileName) succeeded"
                }
                else
                {
                    Write-Host "Removing of file $($download.FileName) failed"
                }
            }
            else
            {
                Write-Host (
                    "Download of $($download.FileName) failed: $($download.Error.Message)")
            }
        }
 
        # Throw on any error
        $synchronizationResult.Check()
    }
    finally
    {
        # Disconnect, clean up
        $session.Dispose()
    }
 
    exit 0
}
catch
{
    Write-Host "Error: $($_.Exception.Message)"
    exit 1
}