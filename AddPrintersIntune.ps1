curl 'https://dl.konicaminolta.eu/en/?tx_kmanacondaimport_downloadproxy[fileId]=8675e59364237da218c420b6746cdca1&tx_kmanacondaimport_downloadproxy[documentId]=122133&tx_kmanacondaimport_downloadproxy[system]=KonicaMinolta&tx_kmanacondaimport_downloadproxy[language]=EN&type=1558521685' -o 'drivers.zip'

Expand-Archive -LiteralPath C:\drivers.zip -DestinationPath C:\drivers -Force

Voorbeeld: (Printer DVP Brussel)

pnputil /add-driver C:\drivers\IT6PCL6Winx64_20130EN\KOAXMJ__.inf
Add-PrinterDriver -Name "KONICA MINOLTA C3320i PCL"

add-printerport -name "Konica_Brussel" -printerhostaddress "10.0.0.106"
add-printer -name "Konica_Brussel" -DriverName "KONICA MINOLTA C3320i PCL" -portname "Konica_Brussel"