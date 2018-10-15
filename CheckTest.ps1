
#Add PC you want checked to this array:
$Global:PCArray = @( 
    "DK-TC100776", "DK-TC100777", "DK-TC100812", "DK-TC100847", "DK-TC100857", "DK-TC101015", "DK-TC101075", "DK-TC101102", "DK-TC101126", "DK-TC101275", 
    "DK-TC101299", "DK-TC101304", "DK-TC101306", "DK-TC101365", "PD100106", "PD100299", "PD100347", "PW00051", "PW00064", "PW00067", "PW00192", "PW00305",
    "PW00323", "PW00327", "PW00332", "PW00462", "PW00485", "PW00503", "PW00535", "PW00536", "PW00544", "PW00549", "PW00568", "PW00569", "PW00589", "PW00735",
    "PW00781", "PW100103", "PW20003", "PW20013", "PX00068", "PX00112", "PX00113", "PX00114", "PX00115", "PX00138", "PX00139", "PX00304", "DK-TC100350",
    "PD100105", "PD100236", "PW00174", "PW00496", "PW00642", "PW00645", "DK-TC100617", "DK-TC101263", "PW00255", "PW00805", "PX00133", "DK-TC100942",
    "DK-TC101170")

$Global:SqlSelect = "SELECT * FROM LaserMgrClassDataCfg"
$Global:Trusted = @("")
$Global:SQL = @("")
$Global:Failed = @("")
$Global:SuccessPing = @("")
$Global:Username = get-content $psscriptroot\Passwords.txt | Select-Object -first 1
$Global:Password = get-content $psscriptroot\Passwords.txt | Select-Object -first 1 -skip 1


foreach ($PC in $Global:PCArray) {
    try {
        Invoke-Sqlcmd -ServerInstance $PC -Database "Marking" -Query $Global:SqlSelect -ErrorAction Stop -QueryTimeout 2 | Out-Null
        $PC + " Trusted"
        $Global:Trusted += $PC
    }
    catch {
        Write-Host "Trusted Connection failed to $PC. Pinging..."
        $Ping = Test-Connection $PC -Quiet -Count 2
        if ($Ping -eq $True) {
            " Ping was successfull!"
            $Global:SuccessPing += $PC
        }
        if ($Ping -eq $False) {
            " Ping failed!"
            $Global:FailedPing += $PC
        }
    }
}
Write-Host "---------------- Trusted test done--------------------"
foreach ($PC in $Global:PCArray) {
    try {
        Invoke-Sqlcmd -ServerInstance $PC -Database "Marking" -Query $Global:SqlSelect -ErrorAction Stop -QueryTimeout 2 -Username $Global:Username -Password $Global:Password | Out-Null
        $PC + " SQL"
        $Global:SQL += $PC
    }
    catch {
        Write-Host "SQL Connection failed to $PC. Pinging..."
        $Ping = Test-Connection $PC -Quiet -Count 2
        if ($Ping -eq $True) {
            " Ping was successfull!"
            $Global:SuccessPing += $PC
        }
        if ($Ping -eq $False) {
            " Ping failed!"
            $Global:FailedPing += $PC
        }
    }
}
Write-Host "---------------- SQL test done --------------------"

Write-Host "---------------- Trusted PC's --------------------"
$Global:Trusted

Write-Host "---------------- SQL PC's --------------------"
$Global:SQL

Write-Host "---------------- Successfull Ping PC's --------------------"
$Global:SuccessPing

Write-Host "---------------- Failed PC's --------------------"
$Global:FailedPing

Read-Host -Prompt "Press Enter to exit."