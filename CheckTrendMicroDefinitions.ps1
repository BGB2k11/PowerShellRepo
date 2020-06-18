
#Set Variables
$hostname = hostname
$7daysago = (get-date).AddDays(-7)
$key = 'HKLM:SOFTWARE\WOW6432Node\TrendMicro\PC-cillinNTCorp\CurrentVersion\Misc.'



#Test for registry key path and execute if neccessary
if (test-path -Path $key)
{

$reg = (Get-ItemProperty -Path $key -Name PatterntooOld).PatterntooOld
$resultText = 'PatterntooOld = '+ [string]$reg + ' day(s)' 

#Write-Host A min ago was $7daysago. DEFs was last written at $writetime

    if ($reg -gt 1){
        echo "You have old defs"
        $notify = "yes"
        echo "<-Start Result->"
        echo "CSMon_Result=Update Needed"
        echo "<-End Result->"
        exit 1
    } else {
        echo "You have current defs"
        exit 0
    } 
}