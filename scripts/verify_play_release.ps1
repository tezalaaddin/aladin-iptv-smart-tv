param(
  [string]$Artifact = "",
  [string]$ExpectedSha1 = "D1:3C:9C:24:EB:9C:10:17:47:81:D1:2B:50:24:AD:8B:CF:8C:11:75"
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$gradle = Get-Content (Join-Path $root 'android/app/build.gradle.kts') -Raw
$manifest = Get-Content (Join-Path $root 'android/app/src/main/AndroidManifest.xml') -Raw
$pubspec = Get-Content (Join-Path $root 'pubspec.yaml') -Raw

if ($gradle -notmatch 'applicationId\s*=\s*"com\.aladin\.iptv\.player\.pro"') { throw 'Paket adı hatalı.' }
if ($gradle -notmatch 'targetSdk\s*=\s*36') { throw 'targetSdk 36 değil.' }
if ($gradle -notmatch 'versionCode\s*=\s*(\d+)') { throw 'versionCode bulunamadı.' }
$code = [int]$Matches[1]
if ($pubspec -notmatch 'version:\s*[^+]+\+(\d+)') { throw 'pubspec build kodu bulunamadı.' }
if ([int]$Matches[1] -ne $code) { throw 'Gradle ve pubspec versionCode eşleşmiyor.' }
if ($manifest -notmatch 'android:banner="@drawable/tv_banner"') { throw 'TV banner manifestte yok.' }
if ($manifest -notmatch 'android:icon="@drawable/tv_launcher_icon"') { throw 'TV icon manifestte yok.' }

Add-Type -AssemblyName System.Drawing
$icon = [Drawing.Image]::FromFile((Join-Path $root 'android/app/src/main/res/drawable-xhdpi/tv_launcher_icon.png'))
$banner = [Drawing.Image]::FromFile((Join-Path $root 'android/app/src/main/res/drawable-xhdpi/tv_banner.png'))
try {
  if ($icon.Width -ne 512 -or $icon.Height -ne 512) { throw 'TV icon 512x512 değil.' }
  if ($banner.Width -ne 320 -or $banner.Height -ne 180) { throw 'TV banner 320x180 değil.' }
} finally { $icon.Dispose(); $banner.Dispose() }

if ($Artifact) {
  $resolved = (Resolve-Path -LiteralPath $Artifact).Path
  if ($resolved.EndsWith('.aab')) {
    $keytool = 'C:\Java\jdk-17.0.19+10\bin\keytool.exe'
    if (-not (Test-Path $keytool)) { $keytool = 'keytool' }
    $cert = & $keytool -printcert -jarfile $resolved | Out-String
    if ($cert -notmatch [regex]::Escape($ExpectedSha1)) { throw 'AAB sertifikası beklenen SHA-1 ile eşleşmiyor.' }
  }
}
Write-Host "PLAY RELEASE CHECK OK - versionCode $code"
