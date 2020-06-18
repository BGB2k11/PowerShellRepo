
#Set Variables
$hostname = hostname
$7daysago = (get-date).AddDays(-7)
$key = 'HKLM:SOFTWARE\Wow6432Node\Symantec\Symantec Endpoint Protection\CurrentVersion\SharedDefs'
$new = 'HKLM:SOFTWARE\Wow6432Node\Symantec\Symantec Endpoint Protection\CurrentVersion\SharedDefs\SDSDefs\'


#Test for registry key path and execute if neccessary
if (test-path -path $new)
{

$path = (Get-ItemProperty -Path $new -Name DEFWATCH_10).DEFWATCH_10
echo $path
$writetime = [datetime](Get-ItemProperty -Path $path -Name LastWriteTime).lastwritetime
#Write-Host A min ago was $7daysago. DEFs was last written at $writetime

    if ($writetime -lt $7daysago){
        echo "You have old defs"
        Write-EventLog -LogName "Application" -Source "Symantec Antivirus" -EventId "7076" -EntryType "Warning" -Message "Symantec Definitions are older than 7 days. Last update time is was $writetime"
        $notify = "yes"
        echo "<-Start Result->"
        echo "CSMon_Result=Update Needed"
        echo "<-End Result->"
        exit 1
    } else {
        echo "You have current defs"
        Write-EventLog -LogName "Application" -Source "Symantec Antivirus" -EventId "7077" -EntryType "Information" -Message "Symantec Definitions are current within 7 days. Last update time is was $writetime"
       exit 0
    } 
}

else {


$path = (Get-ItemProperty -Path $key -Name DEFWATCH_10).DEFWATCH_10
$writetime = [datetime](Get-ItemProperty -Path $path -Name LastWriteTime).lastwritetime
#Write-Host A min ago was $7daysago. DEFs was last written at $writetime

if ($writetime -lt $7daysago) 
{
    echo "You have old defs"
    Write-EventLog -LogName "Application" -Source "Symantec Antivirus" -EventId "7076" -EntryType "Warning" -Message "Symantec Definitions are older than 7 days. Last update time is was $writetime"
    echo "<-Start Result->"
    echo "CSMon_Result=Update Needed"
    echo "<-End Result->"
    exit 1

} else {
    echo "You have current defs"
    Write-EventLog -LogName "Application" -Source "Symantec Antivirus" -EventId "7077" -EntryType "Information" -Message "Symantec Definitions are current within 7 days. Last update time is was $writetime"
    exit 0
    }
}