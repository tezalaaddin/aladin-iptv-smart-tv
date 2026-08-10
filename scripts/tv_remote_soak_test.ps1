param(
    [int]$Minutes = 30,
    [string]$Serial = ""
)

$ErrorActionPreference = 'Stop'
$adbArgs = @()
if ($Serial) { $adbArgs += @('-s', $Serial) }

& adb @adbArgs shell monkey -p com.aladin.iptv.player.pro 1 | Out-Null
$deadline = [DateTime]::UtcNow.AddMinutes($Minutes)
$keys = @(19, 20, 21, 22, 23, 4)
$iteration = 0

while ([DateTime]::UtcNow -lt $deadline) {
    $key = $keys[$iteration % $keys.Count]
    & adb @adbArgs shell input keyevent $key | Out-Null
    Start-Sleep -Milliseconds 350
    $iteration++
}

$fatal = & adb @adbArgs logcat -d -t 4000 '*:E' |
    Select-String -Pattern 'FATAL EXCEPTION|ANR in com.aladin.iptv.player.pro'

if ($fatal) {
    $fatal | ForEach-Object { Write-Error $_.Line }
    exit 1
}

Write-Output "TV remote soak completed: $iteration key events, no FATAL/ANR found."
