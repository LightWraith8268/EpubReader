# Simple build script without Firebase requirements
# For local testing and development builds

[CmdletBinding()]
param(
    [switch]$Android,
    [switch]$Windows,
    [switch]$DebugBuild,
    [switch]$ReleaseBuild
)

$ErrorActionPreference = "Stop"

# Ensure dotnet is in path
$dotnetPath = "C:\Program Files\dotnet"
if (-not ($env:PATH -like "*$dotnetPath*")) {
    $env:PATH = "$dotnetPath;$env:PATH"
}

# Set dummy Firebase values for build process
$env:FIREBASE_API_KEY = "dummy-api-key-for-local-build"
$env:FIREBASE_AUTH_DOMAIN = "dummy-app.firebaseapp.com"
$env:FIREBASE_DATABASE_URL = "https://dummy-app.firebaseio.com"

# Honor -DebugBuild / -ReleaseBuild switches
$Configuration = 'Debug'
if ($ReleaseBuild) {
    $Configuration = 'Release'
}

Write-Host "Building with Configuration: $Configuration" -ForegroundColor Cyan
Write-Host "Note: Using dummy Firebase values - cloud sync will not work" -ForegroundColor Yellow

# Determine target framework
$targetFramework = $null
if ($Android) {
    $targetFramework = 'net10.0-android'
    Write-Host "Building for Android..." -ForegroundColor Green
} elseif ($Windows) {
    $targetFramework = 'net10.0-windows10.0.19041.0'
    Write-Host "Building for Windows..." -ForegroundColor Green
} else {
    throw "Specify either -Android or -Windows"
}

# Build the project
$projectPath = Join-Path $PSScriptRoot "EpubReader\EpubReader.csproj"

Write-Host "Starting build..." -ForegroundColor Cyan
dotnet build $projectPath -f $targetFramework -c $Configuration

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nBuild succeeded!" -ForegroundColor Green

    # Show output location
    $outputPath = Join-Path $PSScriptRoot "EpubReader\bin\$Configuration\$targetFramework"
    if (Test-Path $outputPath) {
        Write-Host "Output location: $outputPath" -ForegroundColor Cyan
        Get-ChildItem $outputPath -Recurse -Include *.exe,*.apk,*.aab | ForEach-Object {
            Write-Host "  - $($_.FullName)" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "`nBuild failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}
