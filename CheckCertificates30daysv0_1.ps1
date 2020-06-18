Set-ExecutionPolicy -ExecutionPolicy Unrestricted
sl cert:
$Expired = @(Get-ChildItem -Recurse | where { $_.notafter -le (get-date).AddDays(30) -AND $_.notafter -gt (get-date)} | select subject)

foreach ($expire in $Expired){
    $cert = $expire.Subject
}

if ([string]::IsNullOrWhitespace($cert)){
    exit 0
} else {
    Write-host "<-Start Result->"
    Write-host "CSMon_Result=" $cert " is out of date in 30 days!"
    Write-host '<-End Result->'
    exit 1
}