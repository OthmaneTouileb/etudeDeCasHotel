# Wrapper pour k6 - Utilise k6 depuis le dossier tools
# Usage: .\scripts\k6-wrapper.ps1 run scripts\k6-test-rest.js

$TOOLS_DIR = "tools"
$K6_EXE = Get-ChildItem -Path $TOOLS_DIR -Filter "k6.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $K6_EXE) {
    Write-Host "k6 non trouvé. Exécutez d'abord: .\scripts\install-k6.ps1" -ForegroundColor Red
    exit 1
}

& $K6_EXE.FullName $args

