$SureClick = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "HP Sure Click"}
$SureSense = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "HP Sure Sense Installer"}
$ClientSecurity = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "HP Client Security Manager"}

    function InstallUpdates {
        Install-PackageProvider -Name NuGet -Force
        Install-Module -Name PSWindowsUpdate -Force
        Get-WindowsUpdate
        Install-WindowsUpdate -AcceptAll -Install -IgnoreReboot        
    }
    function AdjustPcSettings {
         Rename-Computer -ComputerName $env:computername -NewName $ComputerName -LocalCredential $env:computername\Techne -Force
         Set-ItemProperty -Path 'Registry::HKU\.DEFAULT\Control Panel\Keyboard' -Name "InitialKeyboardIndicators" -Value "2"
    }
    function RemoveHPBloatWare {
        $SureClick.Uninstall()
        $SureSense.Uninstall()
        $ClientSecurity.Uninstall()    
    }
 function New-AemApiAccessToken
    {
	    $apiUrl         	=	'https://pinotage-api.centrastage.net'
	    $apiKey         	=	'A69PGAJCNEMQBPISAF8EP4FJKR6S8CA2'
	    $apiSecretKey  	    =	'3AFG9HOE6UA3OM88BCUGE9G8LOI79G6B'

	# Specify security protocols
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'

	# Convert password to secure string
	$securePassword = ConvertTo-SecureString -String 'public' -AsPlainText -Force

	# Define parameters for Invoke-WebRequest cmdlet
	$params = @{
		Credential	=	New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ('public-client', $securePassword)
		Uri			=	'{0}/auth/oauth/token' -f $apiUrl
		Method      =	'POST'
		ContentType = 	'application/x-www-form-urlencoded'
		Body        = 	'grant_type=password&username={0}&password={1}' -f $apiKey, $apiSecretKey
	}
	
	# Request access token
	try {
		(Invoke-WebRequest @params -UseBasicParsing | ConvertFrom-Json).access_token
        }
	catch {$_.Exception}
}

    function InstallAEM($token) {
        If (Test-Path -Path $workdir -PathType Container)
            { Write-Host "$workdir already exists" -ForegroundColor Red}
        ELSE
            { New-Item -Path $workdir  -ItemType directory }

        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Authorization", "Bearer $token")

		$response = Invoke-RestMethod 'https://pinotage-api.centrastage.net/api/v2/account/sites' -Method 'GET' -Headers $headers -Body $body -UseBasicParsing
        $json = $response | ConvertTo-Json

        $objects = $json | ConvertFrom-Json

        $sitename = $Site

        foreach ($site in $objects.sites) {

            if($site.name -eq $sitename
            ) {

                Invoke-Webrequest -URI ('https://pinotage.centrastage.net/csm/profile/downloadAgent/'+$site.uid) -OutFile "C:\Applications\$sitename.exe"

             }
        }
        Start-Process "C:\Applications\$sitename.exe"

	}

    function InstallApplications(){
        ##Adobe Reader Installation
        # Path for the workdir
        $workdir = "c:\Applications\"

        # Check if work directory exists if not create it

        If (Test-Path -Path $workdir -PathType Container)
            { Write-Host "$workdir already exists" -ForegroundColor Red}
        ELSE
            { New-Item -Path $workdir  -ItemType directory }

        # Download the installer

        $source = "ftp://ftp.adobe.com/pub/adobe/reader/win/AcrobatDC/2000920063/AcroRdrDC2000920063_en_US.exe"
        $destination = "$workdir\adobeDC.exe"
        Write-Host("Downloading Adobe Reader....")
        Invoke-WebRequest $source -OutFile $destination

        # Start the installation

        Start-Process -FilePath "$workdir\adobeDC.exe" -ArgumentList "/sPB /rs" -Wait

        # Wait XX Seconds for the installation to finish

        Start-Sleep -s 35

        # Remove the installer

        Remove-Item -Force $workdir\adobe*

        ##VLC INSTALLATION
        Write-Host("Downloading VLC....")
        Invoke-WebRequest -URI "https://download.videolan.org/pub/videolan/vlc/last/win64/vlc-3.0.11-win64.exe" -OutFile "C:\Applications\Vlc.exe"
        Write-Host("Installing VLC....")
        Start-Process -FilePath "C:\Applications\Vlc.exe" -ArgumentList "/L=1033 /S" -wait

        ## Forticlient Installation
        Write-Host("FortiClient Installation")
        Invoke-WebRequest -URI "https://filestore.fortinet.com/forticlient/downloads/FortiClientOnlineInstaller_6.0.exe" -OutFile "C:\Applications\Forticlient.exe"
        Write-Host ("Install Forticlient")
        Start-Process -FilePath "C:\Applications\Forticlient.exe" -ArgumentList "/sPB /rs" -Wait
        
        ##Install Chrome
        Write-Host("Chrome installation....")
        $ChromeInstaller = "ChromeInstaller.exe"; 
        $url='http://dl.google.com/chrome/install/latest/chrome_installer.exe'; 
        $output="C:\Applications\$ChromeInstaller"

        try {
            Invoke-WebRequest -Uri $url -OutFile $output
            $p = Start-Process $output -ArgumentList "/silent","/install" -PassThru -Verb runas -Wait; 

            while (!$p.HasExited) { Start-Sleep -Seconds 1 }

            Write-Output ([PSCustomObject]@{Success=$p.ExitCode -eq 0;Process=$p})
        } catch {
            Write-Output ([PSCustomObject]@{Success=$false;Process=$p;ErrorMessage=$_.Exception.Message;ErrorRecord=$_})
        } finally {
            Remove-Item "C:\Applications\$ChromeInstaller" -ErrorAction SilentlyContinue -Verbose
            }

    }
    function EnterDomain(){
        Write-Host("Please Create VPN + connect ... ")
        Start-Process "C:\Program Files\Fortinet\FortiClient\FortiClient.exe"
        $DomainYes = Read-Host -Prompt 'VPN Tunnel Created + Connected Y/N'

        if($DomainYes -eq 'Y'){
            Write-Host("Entering PC in domain")
            Add-Computer -DomainName $DomainName -Credential $creds
        } else {
            Write-Host("Pc NOT DOMAIN JOINED")
        }

    }

    Write-Host("Pass Domain Creds")
    $creds = Get-Credential
    $ComputerName = Read-Host -Prompt 'Future Computer Name: '
    $Site = Read-Host -Prompt 'SiteName: '
    $DomainName = Read-Host -Promp 'DOMAIN: '
    Write-Host("Installing updates ....")
    InstallUpdates
    Write-Host("ADjusting pc settings ... ")
    AdjustPcSettings
    Write-Host("Removing HP Software....")
    RemoveHPBloatWare
    Write-Host("Getting AEM API token ....")
    $token = New-AemApiAccessToken
    Write-Host $token
    Write-Host("Installing AEM Agent")
    InstallAEM($token)
    Write-Host("Installing Applications....")
    InstallApplications
    Write-Host("Putting PC in Domain....")
    EnterDomain
    Restart-Computer 