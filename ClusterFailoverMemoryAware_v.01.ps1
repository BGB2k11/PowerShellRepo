$Env:servers
$totalmemory = "", ""
$freememory = "" , ""
$combinedmem = ""
$memfulltoint = 0
$memfreetoint = 0
$node_minus1_memory = 0

for($i = 0; $i -lt $servers.Length; $i++ ){
       
        $totalmemory +=  Get-WmiObject -ComputerName $servers[$i] -Query  "SELECT __Server,TotalVisibleMemorySize FROM Win32_OperatingSystem" |
        Select @{l='SystemName';e={$_.__Server}},TotalVisibleMemorySize

        $freememory += Get-WmiObject -ComputerName $servers[$i] -Query  "SELECT __Server,FreePhysicalMemory FROM Win32_OperatingSystem" |
        Select @{l='SystemName';e={$_.__Server}},FreePhysicalMemory

}
foreach($total in $totalmemory){
    $memfulltoint += $total.TotalVisibleMemorySize -as [int]
    $node_minus1_memory = ($total.TotalVisibleMemorySize -as [int])*($servers.Count-1)
}
foreach($free in $freememory){
    $memfreetoint += $free.FreePhysicalMemory -as [int]
}

echo "Total Memory=" $memfulltoint
echo "Free Memory=" $memfreetoint
echo "ClusterMemoryInUse=" ($memfulltoint - $memfreetoint)

$warning = ($memfulltoint - $memfreetoint)


if($warning -ge $node_minus1_memory ) {
    echo "<-Start Result->"
    echo "ClusterMemory=Available Memory is NOT sufficient for Failover!"
    echo "<-End Result->"
} else {
    echo "<-Start Result->"
    echo "ClusterMemory=Available Memory is sufficient for Failover!"
    echo "<-End Result->"
}