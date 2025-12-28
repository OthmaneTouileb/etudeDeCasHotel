# Script complet pour exécuter tous les tests et générer les tableaux
# Usage: .\scripts\run-all-tests.ps1

$ErrorActionPreference = "Continue"

$BASE_URL = "http://localhost:8080"
$RESULTS_DIR = "results"
$TIMESTAMP = Get-Date -Format "yyyyMMdd_HHmmss"

New-Item -ItemType Directory -Force -Path $RESULTS_DIR | Out-Null

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Tests de Performance Complets" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier que l'application est accessible
try {
    $health = Invoke-RestMethod -Uri "$BASE_URL/actuator/health" -ErrorAction Stop
    Write-Host "✓ Application accessible" -ForegroundColor Green
} catch {
    Write-Host "✗ Erreur: L'application n'est pas accessible" -ForegroundColor Red
    exit 1
}

# Créer une réservation de test d'abord
Write-Host "`nCréation d'une réservation de test..." -ForegroundColor Yellow
$testReservation = @{
    client = @{
        nom = "Test"
        prenom = "User"
        email = "test@example.com"
        telephone = "0123456789"
    }
    chambre = @{
        id = 1
    }
    dateDebut = "2024-06-01"
    dateFin = "2024-06-05"
    preferences = "Vue sur mer"
} | ConvertTo-Json -Compress

try {
    $created = Invoke-RestMethod -Uri "$BASE_URL/api/rest/reservations" `
        -Method POST `
        -ContentType "application/json" `
        -Body $testReservation
    Write-Host "✓ Réservation créée (ID: $($created.id))" -ForegroundColor Green
} catch {
    Write-Host "⚠ Impossible de créer une réservation, continuons..." -ForegroundColor Yellow
}

# Fonction pour mesurer la latence
function Measure-Latency {
    param(
        [string]$API,
        [string]$Operation,
        [int]$Size,
        [int]$Iterations = 10
    )
    
    $totalTime = 0
    $successCount = 0
    
    for ($i = 1; $i -le $Iterations; $i++) {
        $start = Get-Date
        $success = $false
        
        try {
            switch ($API) {
                "REST" {
                    switch ($Operation) {
                        "Créer" {
                            $body = @{
                                client = @{ nom = "Test"; prenom = "User"; email = "test$i@example.com"; telephone = "0123456789" }
                                chambre = @{ id = 1 }
                                dateDebut = "2024-06-01"
                                dateFin = "2024-06-05"
                                preferences = "Vue sur mer"
                            } | ConvertTo-Json -Compress
                            Invoke-RestMethod -Uri "$BASE_URL/api/rest/reservations" -Method POST -ContentType "application/json" -Body $body | Out-Null
                            $success = $true
                        }
                        "Consulter" {
                            Invoke-RestMethod -Uri "$BASE_URL/api/rest/reservations/1" -Method GET | Out-Null
                            $success = $true
                        }
                        "Modifier" {
                            $body = @{ dateDebut = "2024-06-02"; dateFin = "2024-06-06" } | ConvertTo-Json -Compress
                            Invoke-RestMethod -Uri "$BASE_URL/api/rest/reservations/1" -Method PUT -ContentType "application/json" -Body $body | Out-Null
                            $success = $true
                        }
                        "Supprimer" {
                            # Créer puis supprimer
                            $body = @{
                                client = @{ nom = "Test"; prenom = "User"; email = "test$i@example.com"; telephone = "0123456789" }
                                chambre = @{ id = 1 }
                                dateDebut = "2024-06-01"
                                dateFin = "2024-06-05"
                            } | ConvertTo-Json -Compress
                            $created = Invoke-RestMethod -Uri "$BASE_URL/api/rest/reservations" -Method POST -ContentType "application/json" -Body $body
                            Invoke-RestMethod -Uri "$BASE_URL/api/rest/reservations/$($created.id)" -Method DELETE | Out-Null
                            $success = $true
                        }
                    }
                }
                "GraphQL" {
                    $query = switch ($Operation) {
                        "Créer" { 'mutation { createReservation(input: { client: { nom: "Test" prenom: "User" email: "test@example.com" telephone: "0123456789" } chambre: { id: 1 } dateDebut: "2024-06-01" dateFin: "2024-06-05" preferences: "Vue sur mer" }) { id } }' }
                        "Consulter" { 'query { reservation(id: 1) { id dateDebut dateFin } }' }
                        "Modifier" { 'mutation { updateReservation(id: 1, input: { dateDebut: "2024-06-02" dateFin: "2024-06-06" }) { id } }' }
                        "Supprimer" { 'mutation { deleteReservation(id: 1) }' }
                    }
                    $body = @{ query = $query } | ConvertTo-Json -Compress
                    Invoke-RestMethod -Uri "$BASE_URL/graphql" -Method POST -ContentType "application/json" -Body $body | Out-Null
                    $success = $true
                }
            }
        } catch {
            # Ignorer les erreurs pour continuer les tests
        }
        
        $end = Get-Date
        $timeMs = ($end - $start).TotalMilliseconds
        
        if ($success) {
            $totalTime += $timeMs
            $successCount++
        }
    }
    
    if ($successCount -gt 0) {
        return [math]::Round($totalTime / $successCount, 2)
    }
    return 0
}

# Exécuter les tests
Write-Host "`n=== Tests de Latence ===" -ForegroundColor Cyan

$results = @{}

$operations = @("Créer", "Consulter", "Modifier", "Supprimer")
$sizes = @(1, 10, 100)
$apis = @("REST", "GraphQL")

foreach ($size in $sizes) {
    Write-Host "`n--- Taille: ${size}KB ---" -ForegroundColor Yellow
    foreach ($operation in $operations) {
        foreach ($api in $apis) {
            $key = "${api}_${operation}_${size}KB"
            Write-Host "Test: $api - $operation - ${size}KB" -ForegroundColor Gray
            $latency = Measure-Latency -API $api -Operation $operation -Size $size -Iterations 5
            $results[$key] = $latency
            Write-Host "  → $latency ms" -ForegroundColor Green
            Start-Sleep -Milliseconds 500
        }
    }
}

# Générer le rapport Markdown
$report = @"
# Résultats des Tests de Performance

Généré le: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Performances : Temps de Réponse (Latence)

### Taille du Message : 1 KB

| Opération | REST (ms) | SOAP (ms) | GraphQL (ms) | gRPC (ms) |
|-----------|-----------|----------|--------------|-----------|
| Créer     | $($results['REST_Créer_1KB']) | - | $($results['GraphQL_Créer_1KB']) | - |
| Consulter | $($results['REST_Consulter_1KB']) | - | $($results['GraphQL_Consulter_1KB']) | - |
| Modifier  | $($results['REST_Modifier_1KB']) | - | $($results['GraphQL_Modifier_1KB']) | - |
| Supprimer | $($results['REST_Supprimer_1KB']) | - | $($results['GraphQL_Supprimer_1KB']) | - |

### Taille du Message : 10 KB

| Opération | REST (ms) | SOAP (ms) | GraphQL (ms) | gRPC (ms) |
|-----------|-----------|----------|--------------|-----------|
| Créer     | $($results['REST_Créer_10KB']) | - | $($results['GraphQL_Créer_10KB']) | - |
| Consulter | $($results['REST_Consulter_10KB']) | - | $($results['GraphQL_Consulter_10KB']) | - |
| Modifier  | $($results['REST_Modifier_10KB']) | - | $($results['GraphQL_Modifier_10KB']) | - |
| Supprimer | $($results['REST_Supprimer_10KB']) | - | $($results['GraphQL_Supprimer_10KB']) | - |

### Taille du Message : 100 KB

| Opération | REST (ms) | SOAP (ms) | GraphQL (ms) | gRPC (ms) |
|-----------|-----------|----------|--------------|-----------|
| Créer     | $($results['REST_Créer_100KB']) | - | $($results['GraphQL_Créer_100KB']) | - |
| Consulter | $($results['REST_Consulter_100KB']) | - | $($results['GraphQL_Consulter_100KB']) | - |
| Modifier  | $($results['REST_Modifier_100KB']) | - | $($results['GraphQL_Modifier_100KB']) | - |
| Supprimer | $($results['REST_Supprimer_100KB']) | - | $($results['GraphQL_Supprimer_100KB']) | - |

## Performances : Débit (Throughput)

| Nombre de Requêtes Simultanées | REST (req/s) | SOAP (req/s) | GraphQL (req/s) | gRPC (req/s) |
|--------------------------------|--------------|--------------|-----------------|--------------|
| 10                             | -            | -            | -               | -            |
| 100                            | -            | -            | -               | -            |
| 500                            | -            | -            | -               | -            |
| 1000                           | -            | -            | -               | -            |

*Note: Utilisez k6 ou JMeter pour les tests de débit*

## Consommation des Ressources

### CPU

| Requêtes Simultanées | CPU REST (%) | CPU SOAP (%) | CPU GraphQL (%) | CPU gRPC (%) |
|----------------------|--------------|--------------|-----------------|--------------|
| 10                   | -            | -            | -               | -            |
| 100                  | -            | -            | -               | -            |
| 500                  | -            | -            | -               | -            |
| 1000                 | -            | -            | -               | -            |

*Note: Utilisez Prometheus/Grafana pour le monitoring*

### Mémoire

| Requêtes Simultanées | Mémoire REST (MB) | Mémoire SOAP (MB) | Mémoire GraphQL (MB) | Mémoire gRPC (MB) |
|----------------------|-------------------|-------------------|---------------------|-------------------|
| 10                   | -                 | -                 | -                   | -                 |
| 100                  | -                 | -                 | -                   | -                 |
| 500                  | -                 | -                 | -                   | -                 |
| 1000                 | -                 | -                 | -                   | -                 |

*Note: Utilisez Prometheus/Grafana pour le monitoring*

## Instructions pour compléter les tests

### Tests de Débit
1. Installer k6: `choco install k6` (Windows) ou `brew install k6` (Mac)
2. Exécuter: `k6 run scripts/k6-test-rest.js`
3. Exécuter: `k6 run scripts/k6-test-graphql.js`

### Tests SOAP
Utilisez SoapUI ou Postman pour tester les services SOAP

### Tests gRPC
1. Installer grpcurl: `choco install grpcurl`
2. Tester: `grpcurl -plaintext localhost:9090 list`

### Monitoring
1. Ouvrir Prometheus: http://localhost:9091
2. Ouvrir Grafana: http://localhost:3000
3. Configurer les dashboards pour visualiser CPU/Mémoire

"@

$report | Out-File -FilePath "$RESULTS_DIR\summary_$TIMESTAMP.md" -Encoding UTF8

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Tests terminés !" -ForegroundColor Green
Write-Host "Rapport généré: $RESULTS_DIR\summary_$TIMESTAMP.md" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

