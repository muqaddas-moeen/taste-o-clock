# Starts payment-server + Flutter app using .env files.
# Usage (from project root):
#   .\scripts\dev_with_payments.ps1

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$serverDir = Join-Path $root "payment-server"
$serverEnv = Join-Path $serverDir ".env"
$clientEnv = Join-Path $root ".env"
$serverEnvExample = Join-Path $serverDir ".env.example"
$clientEnvExample = Join-Path $root ".env.example"

function Ensure-EnvFile($target, $example, $label) {
    if (-not (Test-Path $target)) {
        if (-not (Test-Path $example)) {
            Write-Host "Missing $label example file: $example" -ForegroundColor Red
            exit 1
        }
        Copy-Item $example $target
        Write-Host "Created $label from example — edit it with your Stripe keys." -ForegroundColor Yellow
    }
}

Ensure-EnvFile $serverEnv $serverEnvExample "payment-server/.env"
Ensure-EnvFile $clientEnv $clientEnvExample ".env"

Get-Content $serverEnv | ForEach-Object {
    if ($_ -match '^\s*([^#=]+)=(.*)$') {
        $name = $matches[1].Trim()
        $value = $matches[2].Trim().Trim('"')
        Set-Item -Path "env:$name" -Value $value
    }
}

$port = if ($env:PORT) { $env:PORT } else { "4242" }
$lanIp = (
    Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object {
        $_.IPAddress -notmatch '^127\.' -and
        $_.IPAddress -notmatch '^169\.254\.' -and
        $_.PrefixOrigin -ne "WellKnown"
    } |
    Select-Object -First 1
).IPAddress

if (-not $lanIp) {
    $lanIp = "127.0.0.1"
    Write-Host "Could not detect LAN IP — using 127.0.0.1 (emulator only)" -ForegroundColor Yellow
}

$paymentUrl = "http://${lanIp}:${port}/create-payment-intent"

# Sync payment URL into client .env for the Flutter asset bundle
$clientLines = Get-Content $clientEnv
$updated = $false
$clientLines = $clientLines | ForEach-Object {
    if ($_ -match '^\s*STRIPE_PAYMENT_INTENT_URL=') {
        $updated = $true
        "STRIPE_PAYMENT_INTENT_URL=$paymentUrl"
    } else {
        $_
    }
}
if (-not $updated) {
    $clientLines += "STRIPE_PAYMENT_INTENT_URL=$paymentUrl"
}
Set-Content -Path $clientEnv -Value $clientLines -Encoding UTF8

Write-Host ""
Write-Host "Payment server URL:" -ForegroundColor Cyan
Write-Host "  $paymentUrl"
Write-Host ""
Write-Host "Starting payment-server..." -ForegroundColor Green

Push-Location $serverDir
if (-not (Test-Path "node_modules")) {
    npm install
}
Start-Process -FilePath "node" -ArgumentList "server.js" -WorkingDirectory $serverDir
Pop-Location

Start-Sleep -Seconds 2

Push-Location $root
flutter run
Pop-Location
