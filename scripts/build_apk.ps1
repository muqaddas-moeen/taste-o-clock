# Build release APK using values from `.env` (no secret key in the app).
# Usage: .\scripts\build_apk.ps1

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$clientEnv = Join-Path $root ".env"
$clientEnvExample = Join-Path $root ".env.example"

if (-not (Test-Path $clientEnv)) {
    if (Test-Path $clientEnvExample) {
        Copy-Item $clientEnvExample $clientEnv
        Write-Host "Created .env from .env.example — edit keys before shipping." -ForegroundColor Yellow
    } else {
        Write-Host "Missing .env — copy .env.example to .env and add STRIPE_PUBLISHABLE_KEY" -ForegroundColor Red
        exit 1
    }
}

$publishableKey = $null
$paymentUrl = $null
$apiKey = $null

Get-Content $clientEnv | ForEach-Object {
    if ($_ -match '^\s*STRIPE_PUBLISHABLE_KEY=(.*)$') {
        $publishableKey = $matches[1].Trim().Trim('"')
    }
    if ($_ -match '^\s*STRIPE_PAYMENT_INTENT_URL=(.*)$') {
        $paymentUrl = $matches[1].Trim().Trim('"')
    }
    if ($_ -match '^\s*PAYMENT_API_KEY=(.*)$') {
        $apiKey = $matches[1].Trim().Trim('"')
    }
}

if (-not $publishableKey -or $publishableKey -eq "pk_test_your_publishable_key_here") {
    Write-Host "Set STRIPE_PUBLISHABLE_KEY in .env" -ForegroundColor Yellow
    exit 1
}

if (-not $paymentUrl) {
    Write-Host "Set STRIPE_PAYMENT_INTENT_URL in .env (deployed HTTPS URL or LAN IP)" -ForegroundColor Yellow
    exit 1
}

Push-Location $root

$defines = @(
    "--dart-define=STRIPE_PUBLISHABLE_KEY=$publishableKey",
    "--dart-define=STRIPE_PAYMENT_INTENT_URL=$paymentUrl"
)
if ($apiKey) {
    $defines += "--dart-define=PAYMENT_API_KEY=$apiKey"
}

flutter build apk --release @defines
Pop-Location

Write-Host ""
Write-Host "APK: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Green
