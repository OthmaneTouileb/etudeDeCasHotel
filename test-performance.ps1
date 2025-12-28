# Script PowerShell de test de performance pour comparer REST, SOAP, GraphQL, gRPC
# Usage: .\test-performance.ps1

$ErrorActionPreference = "Stop"

$BASE_URL = "http://localhost:8080"
$GRPC_HOST = "localhost:9090"
$RESULTS_DIR = "results"
$TIMESTAMP = Get-Date -Format "yyyyMMdd_HHmmss"
$RESULTS_FILE = "$RESULTS_DIR\results_$TIMESTAMP.csv"
$SUMMARY_FILE = "$RESULTS_DIR\summary_$TIMESTAMP.md"

# Créer le répertoire de résultats
New-Item -ItemType Directory -Force -Path $RESULTS_DIR | Out-Null

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Test de Performance des APIs" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Fonction pour créer une réservation de test
function Create-TestReservation {
    param([int]$Size)
    
    $preferences = switch ($Size) {
        1 { "Vue sur mer" }
        10 { "Vue sur mer, lit king-size, petit-déjeuner inclus, service de chambre, wifi haut débit, parking privé, accès spa, service de conciergerie, transfert aéroport" }
        100 { "Vue sur mer, " * 500 }
    }
    
    return @{
        client = @{
            nom = "Test"
            prenom = "User"
            email = "test$((Get-Random))@example.com"
            telephone = "0123456789"
        }
        chambre = @{
            id = 1
        }
        dateDebut = "2024-06-01"
        dateFin = "2024-06-05"
        preferences = $preferences
    } | ConvertTo-Json -Compress
}

# Fonction pour mesurer la latence REST
function Test-RestLatency {
    param(
        [string]$Operation,
        [int]$Size,
        [int]$Iterations = 10
    )
    
    Write-Host "Test REST - $Operation - ${Size}KB" -ForegroundColor Yellow
    
    $totalTime = 0
    
    switch ($Operation) {
        "Créer" {
            for ($i = 1; $i -le $Iterations; $i++) {
                $body = Create-TestReservation -Size $Size
                $start = Get-Date
                try {
                    Invoke-RestMethod -Uri "$BASE_URL/api/rest/reservations" `
                        -Method POST `
                        -ContentType "application/json" `
                        -Body $body | Out-Null
                } catch {
                    Write-Host "Erreur: $_" -ForegroundColor Red
                }
                $end = Get-Date
                $timeMs = ($end - $start).TotalMilliseconds
                $totalTime += $timeMs
            }
        }
        "Consulter" {
            for ($i = 1; $i -le $Iterations; $i++) {
                $start = Get-Date
                try {
                    Invoke-RestMethod -Uri "$BASE_URL/api/rest/reservations/1" `
                        -Method GET | Out-Null
                } catch {
                    Write-Host "Erreur: $_" -ForegroundColor Red
                }
                $end = Get-Date
                $timeMs = ($end - $start).TotalMilliseconds
                $totalTime += $timeMs
            }
        }
        "Modifier" {
            for ($i = 1; $i -le $Iterations; $i++) {
                $body = @{
                    dateDebut = "2024-06-02"
                    dateFin = "2024-06-06"
                } | ConvertTo-Json -Compress
                $start = Get-Date
                try {
                    Invoke-RestMethod -Uri "$BASE_URL/api/rest/reservations/1" `
                        -Method PUT `
                        -ContentType "application/json" `
                        -Body $body | Out-Null
                } catch {
                    Write-Host "Erreur: $_" -ForegroundColor Red
                }
                $end = Get-Date
                $timeMs = ($end - $start).TotalMilliseconds
                $totalTime += $timeMs
            }
        }
        "Supprimer" {
            for ($i = 1; $i -le $Iterations; $i++) {
                # Créer d'abord une réservation
                $body = Create-TestReservation -Size 1
                try {
                    $created = Invoke-RestMethod -Uri "$BASE_URL/api/rest/reservations" `
                        -Method POST `
                        -ContentType "application/json" `
                        -Body $body
                    $id = $created.id
                    
                    $start = Get-Date
                    Invoke-RestMethod -Uri "$BASE_URL/api/rest/reservations/$id" `
                        -Method DELETE | Out-Null
                    $end = Get-Date
                    $timeMs = ($end - $start).TotalMilliseconds
                    $totalTime += $timeMs
                } catch {
                    Write-Host "Erreur: $_" -ForegroundColor Red
                }
            }
        }
    }
    
    $avgTime = [math]::Round($totalTime / $Iterations, 2)
    return $avgTime
}

# Fonction pour mesurer la latence GraphQL
function Test-GraphQLLatency {
    param(
        [string]$Operation,
        [int]$Size,
        [int]$Iterations = 10
    )
    
    Write-Host "Test GraphQL - $Operation - ${Size}KB" -ForegroundColor Yellow
    
    $query = switch ($Operation) {
        "Créer" { 'mutation { createReservation(input: { client: { nom: "Test" prenom: "User" email: "test@example.com" telephone: "0123456789" } chambre: { id: 1 } dateDebut: "2024-06-01" dateFin: "2024-06-05" preferences: "Vue sur mer" }) { id } }' }
        "Consulter" { 'query { reservation(id: 1) { id dateDebut dateFin } }' }
        "Modifier" { 'mutation { updateReservation(id: 1, input: { dateDebut: "2024-06-02" dateFin: "2024-06-06" }) { id } }' }
        "Supprimer" { 'mutation { deleteReservation(id: 1) }' }
    }
    
    $totalTime = 0
    
    for ($i = 1; $i -le $Iterations; $i++) {
        $body = @{
            query = $query
        } | ConvertTo-Json -Compress
        
        $start = Get-Date
        try {
            Invoke-RestMethod -Uri "$BASE_URL/graphql" `
                -Method POST `
                -ContentType "application/json" `
                -Body $body | Out-Null
        } catch {
            Write-Host "Erreur: $_" -ForegroundColor Red
        }
        $end = Get-Date
        $timeMs = ($end - $start).TotalMilliseconds
        $totalTime += $timeMs
    }
    
    $avgTime = [math]::Round($totalTime / $Iterations, 2)
    return $avgTime
}

# Fonction pour mesurer le débit avec k6 (si disponible)
function Test-Throughput {
    param(
        [string]$API,
        [int]$Concurrent
    )
    
    Write-Host "Test Débit - $API - $Concurrent requêtes simultanées" -ForegroundColor Yellow
    
    # Pour l'instant, retourner 0 si k6 n'est pas disponible
    # L'utilisateur devra utiliser k6 manuellement
    return 0
}

# Fonction pour mesurer les ressources
function Measure-Resources {
    param(
        [string]$API,
        [int]$Concurrent
    )
    
    Write-Host "Mesure Ressources - $API - $concurrent requêtes" -ForegroundColor Yellow
    
    $stats = docker stats --no-stream --format "{{.CPUPerc}},{{.MemUsage}}" hotel-reservation-api
    $cpu = ($stats -split ',')[0] -replace '%', ''
    $mem = ($stats -split ',')[1] -replace 'MiB.*', ''
    
    return @{
        CPU = [math]::Round([double]$cpu, 2)
        Memory = [math]::Round([double]$mem, 2)
    }
}

# Fonction pour générer le rapport
function Generate-Report {
    $report = @"
# Résultats des Tests de Performance

Généré le: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Performances : Temps de Réponse (Latence)

### Taille du Message : 1 KB

| Opération | REST (ms) | SOAP (ms) | GraphQL (ms) | gRPC (ms) |
|-----------|-----------|----------|--------------|-----------|
| Créer     |           |          |              |           |
| Consulter |           |          |              |           |
| Modifier  |           |          |              |           |
| Supprimer |           |          |              |           |

### Taille du Message : 10 KB

| Opération | REST (ms) | SOAP (ms) | GraphQL (ms) | gRPC (ms) |
|-----------|-----------|----------|--------------|-----------|
| Créer     |           |          |              |           |
| Consulter |           |          |              |           |
| Modifier  |           |          |              |           |
| Supprimer |           |          |              |           |

### Taille du Message : 100 KB

| Opération | REST (ms) | SOAP (ms) | GraphQL (ms) | gRPC (ms) |
|-----------|-----------|----------|--------------|-----------|
| Créer     |           |          |              |           |
| Consulter |           |          |              |           |
| Modifier  |           |          |              |           |
| Supprimer |           |          |              |           |

## Performances : Débit (Throughput)

| Nombre de Requêtes Simultanées | REST (req/s) | SOAP (req/s) | GraphQL (req/s) | gRPC (req/s) |
|--------------------------------|--------------|--------------|-----------------|--------------|
| 10                             |              |              |                 |              |
| 100                            |              |              |                 |              |
| 500                            |              |              |                 |              |
| 1000                           |              |              |                 |              |

## Consommation des Ressources

### CPU

| Requêtes Simultanées | CPU REST (%) | CPU SOAP (%) | CPU GraphQL (%) | CPU gRPC (%) |
|----------------------|--------------|--------------|-----------------|--------------|
| 10                   |              |              |                 |              |
| 100                  |              |              |                 |              |
| 500                  |              |              |                 |              |
| 1000                 |              |              |                 |              |

### Mémoire

| Requêtes Simultanées | Mémoire REST (MB) | Mémoire SOAP (MB) | Mémoire GraphQL (MB) | Mémoire gRPC (MB) |
|----------------------|-------------------|-------------------|---------------------|-------------------|
| 10                   |                   |                   |                     |                   |
| 100                  |                   |                   |                     |                   |
| 500                  |                   |                   |                     |                   |
| 1000                 |                   |                   |                     |                   |

"@
    
    $report | Out-File -FilePath $SUMMARY_FILE -Encoding UTF8
    Write-Host "Rapport généré : $SUMMARY_FILE" -ForegroundColor Green
}

# Menu principal
function Main {
    Write-Host "Démarrage des tests de performance..." -ForegroundColor Cyan
    Write-Host ""
    
    # Vérifier que les services sont démarrés
    try {
        $health = Invoke-RestMethod -Uri "$BASE_URL/actuator/health" -ErrorAction Stop
        Write-Host "✓ Application accessible" -ForegroundColor Green
    } catch {
        Write-Host "Erreur: L'application n'est pas accessible sur $BASE_URL" -ForegroundColor Red
        exit 1
    }
    
    Write-Host ""
    Write-Host "=== Tests de Latence ===" -ForegroundColor Cyan
    
    # Tests REST
    Write-Host "`n--- Tests REST ---" -ForegroundColor Yellow
    $restCreate1 = Test-RestLatency -Operation "Créer" -Size 1
    $restGet1 = Test-RestLatency -Operation "Consulter" -Size 1
    $restUpdate1 = Test-RestLatency -Operation "Modifier" -Size 1
    $restDelete1 = Test-RestLatency -Operation "Supprimer" -Size 1
    
    Write-Host "REST 1KB - Créer: ${restCreate1}ms, Consulter: ${restGet1}ms, Modifier: ${restUpdate1}ms, Supprimer: ${restDelete1}ms"
    
    # Tests GraphQL
    Write-Host "`n--- Tests GraphQL ---" -ForegroundColor Yellow
    $graphqlCreate1 = Test-GraphQLLatency -Operation "Créer" -Size 1
    $graphqlGet1 = Test-GraphQLLatency -Operation "Consulter" -Size 1
    $graphqlUpdate1 = Test-GraphQLLatency -Operation "Modifier" -Size 1
    $graphqlDelete1 = Test-GraphQLLatency -Operation "Supprimer" -Size 1
    
    Write-Host "GraphQL 1KB - Créer: ${graphqlCreate1}ms, Consulter: ${graphqlGet1}ms, Modifier: ${graphqlUpdate1}ms, Supprimer: ${graphqlDelete1}ms"
    
    # Générer le rapport
    Generate-Report
    
    Write-Host ""
    Write-Host "Tests terminés !" -ForegroundColor Green
    Write-Host "Résultats sauvegardés dans : $RESULTS_DIR" -ForegroundColor Green
    Write-Host ""
    Write-Host "Note: Pour les tests complets (SOAP, gRPC, débit, ressources), utilisez:" -ForegroundColor Yellow
    Write-Host "  - JMeter pour les tests de charge" -ForegroundColor Yellow
    Write-Host "  - k6 pour les tests de débit" -ForegroundColor Yellow
    Write-Host "  - Prometheus/Grafana pour le monitoring" -ForegroundColor Yellow
}

Main

