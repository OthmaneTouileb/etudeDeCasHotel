# Script pour installer k6 manuellement (sans droits admin)
# Usage: .\scripts\install-k6.ps1

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Installation de k6" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$K6_VERSION = "v0.48.0"
$K6_URL = "https://github.com/grafana/k6/releases/download/$K6_VERSION/k6-$K6_VERSION-windows-amd64.zip"
$TOOLS_DIR = "tools"
$K6_DIR = "$TOOLS_DIR\k6"

# Créer le dossier tools
Write-Host "Création du dossier tools..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $TOOLS_DIR | Out-Null

# Télécharger k6
Write-Host "Téléchargement de k6..." -ForegroundColor Yellow
$zipFile = "$TOOLS_DIR\k6.zip"
try {
    Invoke-WebRequest -Uri $K6_URL -OutFile $zipFile -UseBasicParsing
    Write-Host "✓ Téléchargement réussi" -ForegroundColor Green
} catch {
    Write-Host "✗ Erreur lors du téléchargement: $_" -ForegroundColor Red
    exit 1
}

# Extraire
Write-Host "Extraction de k6..." -ForegroundColor Yellow
try {
    Expand-Archive -Path $zipFile -DestinationPath $TOOLS_DIR -Force
    Write-Host "✓ Extraction réussie" -ForegroundColor Green
} catch {
    Write-Host "✗ Erreur lors de l'extraction: $_" -ForegroundColor Red
    exit 1
}

# Trouver k6.exe
$k6Exe = Get-ChildItem -Path $TOOLS_DIR -Filter "k6.exe" -Recurse | Select-Object -First 1

if ($k6Exe) {
    Write-Host "✓ k6 trouvé: $($k6Exe.FullName)" -ForegroundColor Green
    
    # Créer un script wrapper
    $wrapperScript = @"
@echo off
"$($k6Exe.FullName)" %*
"@
    
    $wrapperPath = "$TOOLS_DIR\k6.bat"
    $wrapperScript | Out-File -FilePath $wrapperPath -Encoding ASCII
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Installation terminée !" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Pour utiliser k6, exécutez:" -ForegroundColor Yellow
    Write-Host "  .\tools\k6.bat version" -ForegroundColor Cyan
    Write-Host "  .\tools\k6.bat run scripts\k6-test-rest.js" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Ou ajoutez tools\k6.bat à votre PATH" -ForegroundColor Yellow
    
    # Tester
    Write-Host ""
    Write-Host "Test de k6..." -ForegroundColor Yellow
    & $k6Exe.FullName version
} else {
    Write-Host "✗ k6.exe non trouvé après extraction" -ForegroundColor Red
    exit 1
}

# Nettoyer
Remove-Item -Path $zipFile -Force -ErrorAction SilentlyContinue

