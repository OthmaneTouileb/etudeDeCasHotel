# Résultats des Tests de Performance



## Performances : Temps de Réponse (Latence)

### Taille du Message : 1 KB

| Opération | REST (ms) | SOAP (ms) | GraphQL (ms) | gRPC (ms) |
|-----------|-----------|----------|--------------|-----------|
| Créer     | 125.01 | 185.50 | 99.83 | 28.45 |
| Consulter | 9.64 | 45.20 | 60.11 | 8.25 |
| Modifier  | 51.09 | 95.80 | 59.27 | 22.10 |
| Supprimer | 12.30 | 38.60 | 56.93 | 7.85 |

### Taille du Message : 10 KB

| Opération | REST (ms) | SOAP (ms) | GraphQL (ms) | gRPC (ms) |
|-----------|-----------|----------|--------------|-----------|
| Créer     | 145.25 | 220.40 | 105.50 | 35.20 |
| Consulter | 15.80 | 65.30 | 68.90 | 12.50 |
| Modifier  | 68.50 | 125.60 | 72.30 | 28.75 |
| Supprimer | 18.40 | 52.10 | 65.20 | 10.20 |

### Taille du Message : 100 KB

| Opération | REST (ms) | SOAP (ms) | GraphQL (ms) | gRPC (ms) |
|-----------|-----------|----------|--------------|-----------|
| Créer     | 285.60 | 450.80 | 195.40 | 85.30 |
| Consulter | 45.20 | 125.50 | 95.60 | 28.40 |
| Modifier  | 195.80 | 380.20 | 185.30 | 75.60 |
| Supprimer | 35.10 | 95.40 | 88.50 | 22.10 |

## Performances : Débit (Throughput)

| Nombre de Requêtes Simultanées | REST (req/s) | SOAP (req/s) | GraphQL (req/s) | gRPC (req/s) |
|--------------------------------|--------------|--------------|-----------------|--------------|
| 10                             | 850          | 420          | 720             | 1850         |
| 100                            | 1250         | 580          | 980             | 3200         |
| 500                            | 1800         | 750          | 1350            | 4500         |
| 1000                           | 2100         | 820          | 1520            | 5200         |



## Consommation des Ressources

### CPU

| Requêtes Simultanées | CPU REST (%) | CPU SOAP (%) | CPU GraphQL (%) | CPU gRPC (%) |
|----------------------|--------------|--------------|-----------------|--------------|
| 10                   | 18.5         | 28.2         | 22.4           | 12.8         |
| 100                  | 32.6         | 45.8         | 38.5           | 24.2         |
| 500                  | 58.4         | 72.6         | 65.2           | 42.8         |
| 1000                 | 78.5         | 88.2         | 82.4           | 58.6         |


### Mémoire

| Requêtes Simultanées | Mémoire REST (MB) | Mémoire SOAP (MB) | Mémoire GraphQL (MB) | Mémoire gRPC (MB) |
|----------------------|-------------------|-------------------|---------------------|-------------------|
| 10                   | 285               | 385               | 320                 | 245               |
| 100                  | 420               | 580               | 485                 | 360               |
| 500                  | 680               | 920               | 750                 | 520               |
| 1000                 | 950               | 1280              | 1050                | 720               |


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
| Latence Moyenne (ms) | 78.5 | 145.2 | 85.3 | 28.6 |
| Débit Moyen (req/s) | 1500 | 642 | 1142 | 3690 |
| Utilisation CPU Moyenne (%) | 47.0 | 58.7 | 52.1 | 34.6 |
| Utilisation Mémoire Moyenne (MB) | 584 | 791 | 651 | 461 |
| Sécurité | Bonne | Excellente | Bonne | Excellente |
| Simplicité d'Implémentation | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |

### Analyse des Résultats

**Latence :**
- **gRPC** est le plus rapide (28.6 ms en moyenne) grâce au protocole binaire et HTTP/2
- **REST** suit avec 78.5 ms, offrant un bon équilibre performance/simplicité
- **GraphQL** présente 85.3 ms, légèrement plus lent à cause du parsing des queries
- **SOAP** est le plus lent (145.2 ms) à cause du format XML verbeux

**Débit :**
- **gRPC** domine avec 3690 req/s grâce à sa compression binaire et HTTP/2
- **REST** atteint 1500 req/s, performance solide pour un protocole textuel
- **GraphQL** obtient 1142 req/s, impacté par la complexité des queries
- **SOAP** est limité à 642 req/s à cause de la verbosité XML

**Consommation Ressources :**
- **gRPC** est le plus efficace (34.6% CPU, 461 MB RAM)
- **REST** offre un bon équilibre (47% CPU, 584 MB RAM)
- **GraphQL** consomme modérément (52.1% CPU, 651 MB RAM)
- **SOAP** est le plus gourmand (58.7% CPU, 791 MB RAM) à cause du parsing XML

**Recommandations :**
- **Microservices internes** : gRPC pour la performance maximale
- **APIs publiques** : REST pour la simplicité et compatibilité
- **APIs flexibles** : GraphQL pour la flexibilité des requêtes
- **Intégrations entreprise** : SOAP pour la standardisation et sécurité

