param(
    [switch]$UseCurrentBuildNumber
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$pubspecPath = Join-Path $repoRoot 'pubspec.yaml'
$gradleCache = Join-Path $repoRoot '.gradle-build-cache'
$androidUser = Join-Path $repoRoot '.android-build-user'
$pubCache = Join-Path $repoRoot '.pub-build-cache'
$releaseDir = Join-Path $repoRoot 'outputs\releases'

function Assert-InRepo([string]$path) {
    if (-not $path.StartsWith($repoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Path is outside repository: $path"
    }
}

function Copy-Cache([string]$source, [string]$destination, [string[]]$extraArgs) {
    if (-not (Test-Path -LiteralPath $source -PathType Container)) {
        throw "Required local cache was not found: $source"
    }
    New-Item -ItemType Directory -Path $destination -Force | Out-Null
    & robocopy $source $destination /E /XF *.lock *.lck *.tmp /XD .cxx @extraArgs /R:1 /W:1 /NFL /NDL /NJH /NJS /NP
    if ($LASTEXITCODE -gt 7) {
        throw "Cache copy failed with robocopy exit code $LASTEXITCODE"
    }
}

Assert-InRepo $gradleCache
Assert-InRepo $androidUser
Assert-InRepo $pubCache
Assert-InRepo $releaseDir
New-Item -ItemType Directory -Path $gradleCache, $androidUser, $pubCache, $releaseDir -Force | Out-Null

$sourceGradle = Join-Path $env:USERPROFILE '.gradle'
$sourcePub = Join-Path $env:LOCALAPPDATA 'Pub\Cache'

if (-not (Test-Path -LiteralPath (Join-Path $gradleCache 'wrapper\dists') -PathType Container)) {
    Write-Host 'Preparing isolated Gradle cache...'
    Copy-Cache $sourceGradle $gradleCache @('/XD', 'daemon')
}
if (-not (Test-Path -LiteralPath (Join-Path $pubCache 'hosted\pub.dev') -PathType Container)) {
    Write-Host 'Preparing isolated Pub/JNI cache...'
    Copy-Cache $sourcePub $pubCache @()
}

$versionLine = Select-String -LiteralPath $pubspecPath -Pattern '^version:\s*([^+\s]+)\+(\d+)\s*$' | Select-Object -First 1
if ($null -eq $versionLine) { throw 'Could not parse version from pubspec.yaml' }
$versionName = $versionLine.Matches[0].Groups[1].Value
$currentBuild = [int]$versionLine.Matches[0].Groups[2].Value
$targetBuild = if ($UseCurrentBuildNumber) { $currentBuild } else { $currentBuild + 1 }

$isolatedFlutter = Join-Path $repoRoot '.codex-flutter-test-sdk\bin\flutter.bat'
$flutterCommand = if (Test-Path -LiteralPath $isolatedFlutter -PathType Leaf) {
    $isolatedFlutter
} else {
    (Get-Command flutter -ErrorAction Stop).Source
}
$env:GRADLE_USER_HOME = $gradleCache
$env:ANDROID_USER_HOME = $androidUser
$env:PUB_CACHE = $pubCache
$env:DART_SUPPRESS_ANALYTICS = 'true'
$env:FLUTTER_SUPPRESS_ANALYTICS = 'true'
$env:CI = 'true'

Push-Location $repoRoot
try {
    & $flutterCommand --suppress-analytics pub get --offline
    if ($LASTEXITCODE -ne 0) { throw 'Offline pub get failed' }

    & $flutterCommand --suppress-analytics build apk --release --no-pub --build-name $versionName --build-number $targetBuild
    if ($LASTEXITCODE -ne 0) { throw 'Release APK build failed' }

    $builtApk = Join-Path $repoRoot 'build\app\outputs\flutter-apk\app-release.apk'
    if (-not (Test-Path -LiteralPath $builtApk -PathType Leaf)) { throw 'Built APK was not found' }

    $aapt = Get-ChildItem (Join-Path $env:ANDROID_HOME 'build-tools') -Filter aapt.exe -Recurse |
        Sort-Object FullName -Descending | Select-Object -First 1
    if ($null -eq $aapt) { throw 'aapt.exe was not found' }
    $badging = & $aapt.FullName dump badging $builtApk | Select-Object -First 1
    if ($badging -notmatch "versionCode='$targetBuild'" -or $badging -notmatch "versionName='$([regex]::Escape($versionName))'") {
        throw "APK version verification failed: $badging"
    }

    $archiveName = "aladin-IPTV-Player-Pro-TV_v${versionName}_build${targetBuild}.apk"
    $archivePath = Join-Path $releaseDir $archiveName
    Copy-Item -LiteralPath $builtApk -Destination $archivePath -Force

    if (-not $UseCurrentBuildNumber) {
        $pubspec = Get-Content -LiteralPath $pubspecPath -Raw
        $updated = [regex]::Replace($pubspec, '(?m)^version:\s*[^\r\n]+$', "version: $versionName+$targetBuild", 1)
        $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
        [System.IO.File]::WriteAllText($pubspecPath, $updated, $utf8NoBom)
    }

    $hash = (Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash
    Write-Host "RELEASE_APK=$archivePath"
    Write-Host "VERSION=$versionName+$targetBuild"
    Write-Host "SHA256=$hash"
} finally {
    Pop-Location
}
