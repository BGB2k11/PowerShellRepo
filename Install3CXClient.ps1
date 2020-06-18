msiexec.exe /i location\vc_red.msi /qn /norestart
start /w location\vc_redist.x86.exe /s /v" /qn /norestart"
msiexec.exe /i location\3CXPhoneforWindows15.msi /qn /norestart /L*V C:\example.log