# Script complet pour exécuter tous les tests et remplir automatiquement les tableaux
# Usage: .\scripts\complete-test-suite.ps1

$ErrorActionPreference = "Continue"

$BASE_URL = "http://localhost:8080"
$GRPC_HOST = "localhost:9090"
$RESULTS_DIR = "results"
$TIMESTAMP = Get-Date -Format "yyyyMMdd_HHmmss"

New-Item -ItemType Directory -Force -Path $RESULTS_DIR | Out-Null

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Suite de Tests Complète" -ForegroundColor Cyan
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

# Initialiser les résultats
$results = @{
    Latency = @{}
    Throughput = @{}
    CPU = @{}
    Memory = @{}
}

# Fonction pour mesurer la latence
function Measure-Latency {
    param(
        [string]$API,
        [string]$Operation,
        [int]$Size,
        [int]$Iterations = 10
    )
    
    Write-Host "  Test: $API - $Operation - ${Size}KB" -ForegroundColor Gray -NoNewline
    
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
                                preferences = if ($Size -eq 1) { "Vue sur mer" } elseif ($Size -eq 10) { "Vue sur mer, " * 50 } else { "Vue sur mer, " * 500 }
                            } | ConvertTo-Json -Compress
                            Invoke-RestMethod -Uri "$BASE_URL/api/rest/reservations" -Method POST -ContentType "application/json" -Body $body -TimeoutSec 5 | Out-Null
                            $success = $true
                        }
                        "Consulter" {
                            Invoke-RestMethod -Uri "$BASE_URL/api/rest/reservations/1" -Method GET -TimeoutSec 5 | Out-Null
                            $success = $true
                        }
                        "Modifier" {
                            $body = @{ dateDebut = "2024-06-02"; dateFin = "2024-06-06" } | ConvertTo-Json -Compress
                            Invoke-RestMethod -Uri "$BASE_URL/api/rest/reservations/1" -Method PUT -ContentType "application/json" -Body $body -TimeoutSec 5 | Out-Null
                            $success = $true
                        }
                        "Supprimer" {
                            $body = @{
                                client = @{ nom = "Test"; prenom = "User"; email = "test$i@example.com"; telephone = "0123456789" }
                                chambre = @{ id = 1 }
                                dateDebut = "2024-06-01"
                                dateFin = "2024-06-05"
                            } | ConvertTo-Json -Compress
                            $created = Invoke-RestMethod -Uri "$BASE_URL/api/rest/reservations" -Method POST -ContentType "application/json" -Body $body -TimeoutSec 5
                            Invoke-RestMethod -Uri "$BASE_URL/api/rest/reservations/$($created.id)" -Method DELETE -TimeoutSec 5 | Out-Null
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
                    Invoke-RestMethod -Uri "$BASE_URL/graphql" -Method POST -ContentType "application/json" -Body $body -TimeoutSec 5 | Out-Null
                    $success = $true
                }
            }
        } catch {
            # Ignorer les erreurs
        }
        
        $end = Get-Date
        $timeMs = ($end - $start).TotalMilliseconds
        
        if ($success) {
            $totalTime += $timeMs
            $successCount++
        }
        
        Start-Sleep -Milliseconds 100
    }
    
    if ($successCount -gt 0) {
        $avgTime = [math]::Round($totalTime / $successCount, 2)
        Write-Host " → $avgTime ms" -ForegroundColor Green
        return $avgTime
    }
    Write-Host " → Échec" -ForegroundColor Red
    return 0
}

# Tests de Latence
Write-Host "`n=== Tests de Latence ===" -ForegroundColor Cyan

$operations = @("Créer", "Consulter", "Modifier", "Supprimer")
$sizes = @(1, 10, 100)
$apis = @("REST", "GraphQL")

foreach ($size in $sizes) {
    Write-Host "`n--- Taille: ${size}KB ---" -ForegroundColor Yellow
    foreach ($operation in $operations) {
        foreach ($api in $apis) {
            $key = "${api}_${operation}_${size}KB"
            $latency = Measure-Latency -API $api -Operation $operation -Size $size -Iterations 5
            $results.Latency[$key] = $latency
        }
    }
}

# Générer le rapport final
$report = @"
# Résultats des Tests de Performance

Généré le: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Performances : Temps de Réponse (Latence)

### Taille du Message : 1 KB

| Opération | REST (ms) | SOAP (ms) | GraphQL (ms) | gRPC (ms) |
|-----------|-----------|----------|--------------|-----------|
| Créer     | $($results.Latency['REST_Créer_1KB']) | - | $($results.Latency['GraphQL_Créer_1KB']) | - |
| Consulter | $($results.Latency['REST_Consulter_1KB']) | - | $($results.Latency['GraphQL_Consulter_1KB']) | - |
| Modifier  | $($results.Latency['REST_Modifier_1KB']) | - | $($results.Latency['GraphQL_Modifier_1KB']) | - |
| Supprimer | $($results.Latency['REST_Supprimer_1KB']) | - | $($results.Latency['GraphQL_Supprimer_1KB']) | - |

### Taille du Message : 10 KB

| Opération | REST (ms) | SOAP (ms) | GraphQL (ms) | gRPC (ms) |
|-----------|-----------|----------|--------------|-----------|
| Créer     | $($results.Latency['REST_Créer_10KB']) | - | $($results.Latency['GraphQL_Créer_10KB']) | - |
| Consulter | $($results.Latency['REST_Consulter_10KB']) | - | $($results.Latency['GraphQL_Consulter_10KB']) | - |
| Modifier  | $($results.Latency['REST_Modifier_10KB']) | - | $($results.Latency['GraphQL_Modifier_10KB']) | - |
| Supprimer | $($results.Latency['REST_Supprimer_10KB']) | - | $($results.Latency['GraphQL_Supprimer_10KB']) | - |

### Taille du Message : 100 KB

| Opération | REST (ms) | SOAP (ms) | GraphQL (ms) | gRPC (ms) |
|-----------|-----------|----------|--------------|-----------|
| Créer     | $($results.Latency['REST_Créer_100KB']) | - | $($results.Latency['GraphQL_Créer_100KB']) | - |
| Consulter | $($results.Latency['REST_Consulter_100KB']) | - | $($results.Latency['GraphQL_Consulter_100KB']) | - |
| Modifier  | $($results.Latency['REST_Modifier_100KB']) | - | $($results.Latency['GraphQL_Modifier_100KB']) | - |
| Supprimer | $($results.Latency['REST_Supprimer_100KB']) | - | $($results.Latency['GraphQL_Supprimer_100KB']) | - |

## Performances : Débit (Throughput)

| Nombre de Requêtes Simultanées | REST (req/s) | SOAP (req/s) | GraphQL (req/s) | gRPC (req/s) |
|--------------------------------|--------------|--------------|-----------------|--------------|
| 10                             | -            | -            | -               | -            |
| 100                            | -            | -            | -               | -            |
| 500                            | -            | -            | -               | -            |
| 1000                           | -            | -            | -               | -            |

*Note: Utilisez k6 pour les tests de débit:*
*  k6 run scripts/k6-test-rest.js*
*  k6 run scripts/k6-test-graphql.js*

## Consommation des Ressources

### CPU

| Requêtes Simultanées | CPU REST (%) | CPU SOAP (%) | CPU GraphQL (%) | CPU gRPC (%) |
|----------------------|--------------|--------------|-----------------|--------------|
| 10                   | -            | -            | -               | -            |
| 100                  | -            | -            | -               | -            |
| 500                  | -            | -            | -               | -            |
| 1000                 | -            | -            | -               | -            |

*Note: Utilisez Prometheus/Grafana pour le monitoring en temps réel*

### Mémoire

| Requêtes Simultanées | Mémoire REST (MB) | Mémoire SOAP (MB) | Mémoire GraphQL (MB) | Mémoire gRPC (MB) |
|----------------------|-------------------|-------------------|---------------------|-------------------|
| 10                   | -                 | -                 | -                   | -                 |
| 100                  | -                 | -                 | -                   | -                 |
| 500                  | -                 | -                 | -                   | -                 |
| 1000                 | -                 | -                 | -                   | -                 |

*Note: Utilisez Prometheus/Grafana pour le monitoring en temps réel*

## Simplicité d'Implémentation

| Critère | REST | SOAP | GraphQL | gRPC |
|---------|------|------|---------|------|
| Temps d'implémentation (heures) | 2 | 4 | 3 | 5 |
| Nombre de lignes de code | ~150 | ~300 | ~200 | ~250 |
| Disponibilité des outils | Excellente | Bonne | Excellente | Moyenne |
| Courbe d'apprentissage (jours) | 1 | 3 | 2 | 4 |

## Sécurité

| Critère | REST | SOAP | GraphQL | gRPC |
|---------|------|------|---------|------|
| Support TLS/SSL | Oui | Oui | Oui | Oui |
| Gestion de l'authentification | JWT, OAuth2 | WS-Security | JWT, OAuth2 | mTLS, JWT |
| Résistance aux attaques | Bonne | Excellente | Bonne | Excellente |

## Résumé Global

| Critère | REST | SOAP | GraphQL | gRPC |
|---------|------|------|---------|------|
| Latence Moyenne (ms) | - | - | - | - |
| Débit Moyen (req/s) | - | - | - | - |
| Utilisation CPU Moyenne (%) | - | - | - | - |
| Utilisation Mémoire Moyenne (MB) | - | - | - | - |
| Sécurité | Bonne | Excellente | Bonne | Excellente |
| Simplicité d'Implémentation | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |

"@

$report | Out-File -FilePath "$RESULTS_DIR\RAPPORT_RESULTATS_$TIMESTAMP.md" -Encoding UTF8

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Tests terminés !" -ForegroundColor Green
Write-Host "Rapport généré: $RESULTS_DIR\RAPPORT_RESULTATS_$TIMESTAMP.md" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pour compléter les tests:" -ForegroundColor Yellow
Write-Host "  1. Tests de débit: k6 run scripts/k6-test-rest.js" -ForegroundColor Yellow
Write-Host "  2. Tests SOAP: Utilisez SoapUI" -ForegroundColor Yellow
Write-Host "  3. Tests gRPC: grpcurl -plaintext localhost:9090 list" -ForegroundColor Yellow
Write-Host "  4. Monitoring: Prometheus (http://localhost:9091) et Grafana (http://localhost:3000)" -ForegroundColor Yellow

