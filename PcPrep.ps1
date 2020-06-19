Set-ExecutionPolicy RemoteSigned
Install-PackageProvider -Name NuGet -Force
Install-Module -Name PSWindowsUpdate -Force
Get-WindowsUpdate
Install-WindowsUpdate -AcceptAll -Install -AutoReboot