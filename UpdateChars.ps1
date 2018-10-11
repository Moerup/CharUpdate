$Global:DBNAME = "marking" 
$Global:Username = get-content $psscriptroot\Passwords.txt | Select-Object -first 1
$Global:Password = get-content $psscriptroot\Passwords.txt | Select-Object -first 1 -skip 1
$Global:Table = "dbo.LaserMgrClassDataCfg"

#Change Char value:
$Global:Char = 'COMBVDECODE'

$Global:PCArrayTrusted =  @( 
"DK-TC100776", "DK-TC100777", "DK-TC100812", "DK-TC100847", "DK-TC100857",  
"PD100106", "PD100299", "PD100347", "PW00305", "PW00323", "PW00327", "PW00332", "PW00462", 
"PW00485", "PW00503", "PW00535", "PW00536", "PW00544", "PW00549", "PW00568", 
"PW00569", "PW00589", "PW00735", "PW00781", "PW100103", "PW20013", "PX00138", 
"PX00139", "DK-TC100350","PD100105", "PD100236", "PW00174", "PW00496", "PW00642", "PW00645", "DK-TC100617")

$Global:PCArraySQL =  @( 
"DK-TC100776", "DK-TC100777", "DK-TC100812", "DK-TC100847", "DK-TC100857", 
"DK-TC101015", "DK-TC101102", "DK-TC101126", "DK-TC101275", "DK-TC101299", 
"DK-TC101304", "DK-TC101306", "DK-TC101365", "PW00051", "PW00064", "PW00192", "PW20003",
"PX00068", "PX00112", "PX00113", "PX00114", "PX00115", "DK-TC100350", "PW00496")

$Global:SqlSelect = "SELECT * FROM LaserMgrClassDataCfg WHERE VarName = '{0}'" -f $Global:Char
$Global:SqlInsert = "INSERT INTO LaserMgrClassDataCfg(VarName) VALUES ('{0}')" -f $Global:Char

$Global:UpdatedChars = @("")
$Global:AlreadyChars = @("")
$Global:PingFailed = @("")
$Global:PingSuccesfull = @("")

ForEach($PC in $Global:PCArraySQL){
    Try 
    { 

    $SqlReturn = Invoke-Sqlcmd -ServerInstance $PC -Database "Marking" -Query $Global:SqlSelect -ErrorAction Stop -QueryTimeout 2 -Username $Global:Username -Password $Global:Password
    if ($null -ne $SqlReturn) {
        Write-Host "Characteristic already on $PC"
        $Global:AlreadyChars += $PC
    }
    if ($null -eq $SqlReturn) {
        Invoke-Sqlcmd -ServerInstance $PC -Database "Marking" -Query $Global:SqlInsert
        Write-Host "Chraracteristic updated on $PC"
        $Global:UpdatedChars += $PC
    } 
    } 
    catch 
    {
        Write-Host "SQL Connection failed to $PC. Pinging.."
        $Ping = Test-Connection $PC -Quiet -Count 2
        if ($Ping -eq $True) {
            Write-Host "Ping was succesfull. Manually check PC!"
            $Global:PingSuccesfull += $PC
        }
        if ($Ping -eq $False) {
            Write-Host "Ping failed!"
            $Global:PingFailed += $PC
        }
    }
}
Write-Host "--------------- SQL Connections done ---------------------"
ForEach($PC in $Global:PCArrayTrusted){
    Try 
    { 

    $SqlReturn = Invoke-Sqlcmd -ServerInstance $PC -Database "Marking" -Query $Global:SqlSelect -ErrorAction Stop -QueryTimeout 2
    if ($null -ne $SqlReturn) {
        Write-Host "Characteristic already on $PC"
        $Global:AlreadyChars += $PC
    }
    if ($null -eq $SqlReturn) {
        Invoke-Sqlcmd -ServerInstance $PC -Database "Marking" -Query $Global:SqlInsert
        Write-Host "Chraracteristic updated on $PC"
        $Global:UpdatedChars += $PC
    } 
    } 
    catch 
    {
        Write-Host "Trusted Connection failed to $PC. Pinging.."
        $Ping = Test-Connection $PC -Quiet -Count 2
        if ($Ping -eq $True) {
            Write-Host "Ping was succesfull. Manually check PC!"
            $Global:PingSuccesfull += $PC
        }
        if ($Ping -eq $False) {
            Write-Host "Ping failed!"
            $Global:PingFailed += $PC
        }
    }
}
Write-Host "--------------- Trusted Connections done ---------------------"
Write-host ""

Write-Host "--------------- Characteristics already exists: ---------------------"
Write-host ""
$Global:AlreadyChars

Write-Host "--------------- Characteristics updated on these PC'S: ---------------------"
Write-host ""
$Global:UpdatedChars

Write-Host "--------------- SQl statement failed, but ping succesfull: ---------------------"
Write-host ""
$Global:PingSuccesfull

Write-Host "--------------- SQL statement failed, but ping failed: ---------------------"
Write-host ""
$Global:PingFailed

$Time = Get-Date -Format 'yyyy/dd/MM/ HH;mm'
$Directory = "$PSScriptRoot" + '\{0}.txt' -f $Time
"Characteristic already on PC: ", "$Global:AlreadyChars", "Updated characteristics on PC: ", "$Global:UpdatedChars", "Ping successfull, but SQL failed on PC: ", "$Global:PingSuccesfull", "Ping failed, manual check on PC: ", "$Global:PingFailed" | Out-File($Directory)

Read-Host -Prompt "Press Enter to exit."