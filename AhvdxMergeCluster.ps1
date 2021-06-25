$VMName = "EXTSRVDCOFP"

$VMHost = "EXT-NODE2"

$VMInfo = Get-VM $VMName
$VMDisks = Get-VM -Name $VMName | Get-VMHardDiskDrive
$VMDifferencialDisks = $VMDisks | ? {$_.Path -like "*.avhdx"}

$MergeVHDDestinationPath = @()
If ($VMInfo) {
            # Check VM State -> The VM must PowerOff
            If ($VMInfo.State -eq "Off") {
                Write-Verbose "VERBOSE: The VM ($VMInfo.Name) is on the Hyper-V Node ($VMHost)" 
 
                #Check has the VM DifferencialDisks
                If ($VMDifferencialDisks) {
                    Write-Verbose "Info: The VM ($VMInfo.Name) on the Hyper-V Node ($VMHost) has DifferencialDisks"

                     Foreach ($VMDifferencialDisk in $VMDifferencialDisks) {
                        Write-Verbose "Info: Running Merge-Process for Disk $($VMDifferencialDisk.Path)"
 
                        $VMDifferencialDisksIdentifier = $VMDifferencialDisk | Select ControllerNumber, ControllerLocation
                        $VMDifferencialDiskConfigured = $VMDifferencialDisk.Path -split "\\" | select -Last 1
                        $VMDifferencialDiskConfiguredLocation = (($VMDifferencialDisk.Path).Replace("$VMDifferencialDiskConfigured","")).Trim("\") #If the VM Disks are not all in the same location
                        $StringwithoutAVHDX = ($VMDifferencialDiskConfigured.Trim(".avhdx")) #String: Remove .AVHDX at the end
                        $StringwithoutGUID = $StringwithoutAVHDX.Substring(0, $StringwithoutAVHDX.Length-37) #String: Remove GUID and the "_" at the end
 
                        $MergeVHDDestinationPath += ((ls $VMDifferencialDiskConfiguredLocation | ? {($_.Name -like "*.vhdx") -and ($_.Name -match $StringwithoutGUID)})).FullName
 
                        Write-Host "$MergeVHDDestinationPath" -ForegroundColor DarkMagenta #-> Debugging
                        #Write-host ((ls $VMDifferencialDiskConfiguredLocation | ? {($_.Name -like "*.vhdx") -and ($_.Name -match $StringwithoutGUID)})).FullName #-> Debugging
 
                        Merge-VHD -Path ($VMDifferencialDisk.Path) -DestinationPath ((ls $VMDifferencialDiskConfiguredLocation | ? {($_.Name -like "*.vhdx") -and ($_.Name -match $StringwithoutGUID)})).FullName
                        Write-Host "SUCCESS: Merge-Process for Disk $($VMDifferencialDisk.Path) completed" -ForegroundColor Green
                        Remove-Item -Path "$($VMDifferencialDisk.Path).mrt" -Force -ErrorAction SilentlyContinue
                        Remove-Item -Path "$($VMDifferencialDisk.Path).rct" -Force -ErrorAction SilentlyContinue
 
                    } 
                    Write-Host "IMPORTANT: ---> Please configure the original .VHDX in Failover Cluster Manager (Select the ParentDisk (.vhdx) for each Disk) -> It is not possible with VMM" -ForegroundColor Magenta
 
                } Else {
                    Write-Verbose "Info: The VM ($VMInfo.Name) has no AVHDX-Disks"
                }
            } Else {
                Write-Host "Error: The VM ($VMInfo.Name) is not in a supported State" -ForegroundColor Red
            }
        } Else {
            Write-Host "Error: Cannot find the selected VM ($VMInfo.Name) on the Hyper-V Node ($UsinVMHost)" -ForegroundColor Red
        }
   Write-Output $MergeVHDDestinationPath
