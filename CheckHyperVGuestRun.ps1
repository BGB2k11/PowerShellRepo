$vms = Get-VM | Where { $_.State -eq 'Running' }
$threshold = $env:ProcessorPercent
$alert = ''
$arrayAverages = @()
$averageTotal = ''
$name = ''

Foreach ( $vm in $vms ) {

   Write-Host 'Status: {0} `n ---------- `n' $vm.Name

   $processors = Get-VMProcessor -VMName $vm.Name

   Foreach ( $processor in $processors ) {

      $procCount = $processor.Count 

      for($i = 0 ; $i -le $procCount-1; $i++){

      $fullcounter = "\\" + $env:computername + "\Hyper-V Hypervisor Virtual Processor(" + $vm.Name + ":Hv VP " + $i + ")\% Guest Run Time"
     
         
          $ret = Get-Counter -Counter $fullcounter -SampleInterval 1 -MaxSamples 45 `
                 | Select-Object -ExpandProperty CounterSamples `
               | Group-Object -Property InstanceName `
               | ForEach-Object { 
                  $_ | Select-Object -Property Name, @{n='Average';e= {($_.Group.CookedValue | Measure-Object -Average).Average}};
                }
         Write-Host "Counter average: $ret"
         $arrayAverages += $ret.Average
         Write-Host $arrayAverages
         $name = $ret.Name

 
      }
         $averageTotal = 0
         for($i = 0 ; $i -le $arrayAverages.Count; $i++){
            $averageTotal += $arrayAverages[$i]
    
         }
         [double] $average = [double]$averageTotal/$procCount
         Write-Host $average

         if($average -ge $threshold){
            $alert = $name + "is above" + $threshold + "%!"
            Write-Host "<-Start Result->"
            Write-Host "Value="$alert
            Write-Host "<-End Result->"
            exit 1
         }
         $alert = $average

      $arrayAverages  = @()

   }
}
Write-Host "<-Start Result->"
Write-Host "Value="$alert
Write-Host "<-End Result->"
exit 0