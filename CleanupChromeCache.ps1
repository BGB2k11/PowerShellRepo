$arrayNAmes = Get-ChildItem -Path C:\Users\ -Directory -Force -ErrorAction SilentlyContinue | Select-Object Name

for ($i = 0; $i -lt $arrayNames.Length; $i++ ) {
    $Username = $arrayNAmes[$i].Name;
    echo $Username
    $fullpath = "c:\users\" + $Username + "\AppData\Local\Google\Chrome\User Data\Default\Cache\"
    
    $checkfile = Test-Path $fullpath


    if($checkfile){
        Remove-Item –path $fullpath –recurse -Force -EA SilentlyContinue -Verbose
    } else {
        echo "not found"
    }
}