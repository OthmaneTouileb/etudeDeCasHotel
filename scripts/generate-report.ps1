# Script pour générer un rapport à partir des résultats
# Usage: .\scripts\generate-report.ps1

param(
    [string]$ResultsFile = "results\results.csv"
)

$template = @"
# Résultats des Tests de Performance

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

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outputFile = "results\RAPPORT_RESULTATS_$timestamp.md"

$template | Out-File -FilePath $outputFile -Encoding UTF8

Write-Host "Rapport généré: $outputFile" -ForegroundColor Green
Write-Host "Remplissez les valeurs manuellement ou exécutez les scripts de test" -ForegroundColor Yellow

