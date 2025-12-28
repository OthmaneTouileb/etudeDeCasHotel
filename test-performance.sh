#!/bin/bash

# Script de test de performance pour comparer REST, SOAP, GraphQL, gRPC
# Usage: ./test-performance.sh

set -e

BASE_URL="http://localhost:8080"
GRPC_HOST="localhost:9090"
RESULTS_DIR="results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULTS_FILE="$RESULTS_DIR/results_$TIMESTAMP.csv"
SUMMARY_FILE="$RESULTS_DIR/summary_$TIMESTAMP.md"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Créer le répertoire de résultats
mkdir -p "$RESULTS_DIR"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Test de Performance des APIs${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Fonction pour créer une réservation de test
create_test_reservation() {
    local size=$1
    local preferences=""
    
    case $size in
        1)
            preferences="Vue sur mer"
            ;;
        10)
            preferences="Vue sur mer, lit king-size, petit-déjeuner inclus, service de chambre, wifi haut débit, parking privé, accès spa, service de conciergerie, transfert aéroport"
            ;;
        100)
            preferences=$(python3 -c "print('Vue sur mer, ' * 500)" 2>/dev/null || echo "Vue sur mer, " | head -c 100000)
            ;;
    esac
    
    echo "{\"client\":{\"nom\":\"Test\",\"prenom\":\"User\",\"email\":\"test$RANDOM@example.com\",\"telephone\":\"0123456789\"},\"chambre\":{\"id\":1},\"dateDebut\":\"2024-06-01\",\"dateFin\":\"2024-06-05\",\"preferences\":\"$preferences\"}"
}

# Fonction pour mesurer la latence REST
test_rest_latency() {
    local operation=$1
    local size=$1
    local iterations=10
    local total_time=0
    
    echo -e "${YELLOW}Test REST - $operation - ${size}KB${NC}"
    
    case $operation in
        "Créer")
            for i in $(seq 1 $iterations); do
                start=$(date +%s%N)
                curl -s -X POST "$BASE_URL/api/rest/reservations" \
                    -H "Content-Type: application/json" \
                    -d "$(create_test_reservation $size)" > /dev/null
                end=$(date +%s%N)
                time_ms=$(( (end - start) / 1000000 ))
                total_time=$((total_time + time_ms))
            done
            ;;
        "Consulter")
            for i in $(seq 1 $iterations); do
                start=$(date +%s%N)
                curl -s "$BASE_URL/api/rest/reservations/1" > /dev/null
                end=$(date +%s%N)
                time_ms=$(( (end - start) / 1000000 ))
                total_time=$((total_time + time_ms))
            done
            ;;
        "Modifier")
            for i in $(seq 1 $iterations); do
                start=$(date +%s%N)
                curl -s -X PUT "$BASE_URL/api/rest/reservations/1" \
                    -H "Content-Type: application/json" \
                    -d "{\"dateDebut\":\"2024-06-02\",\"dateFin\":\"2024-06-06\"}" > /dev/null
                end=$(date +%s%N)
                time_ms=$(( (end - start) / 1000000 ))
                total_time=$((total_time + time_ms))
            done
            ;;
        "Supprimer")
            for i in $(seq 1 $iterations); do
                # Créer d'abord une réservation
                id=$(curl -s -X POST "$BASE_URL/api/rest/reservations" \
                    -H "Content-Type: application/json" \
                    -d "$(create_test_reservation 1)" | jq -r '.id')
                start=$(date +%s%N)
                curl -s -X DELETE "$BASE_URL/api/rest/reservations/$id" > /dev/null
                end=$(date +%s%N)
                time_ms=$(( (end - start) / 1000000 ))
                total_time=$((total_time + time_ms))
            done
            ;;
    esac
    
    avg_time=$((total_time / iterations))
    echo "$avg_time"
}

# Fonction pour mesurer la latence GraphQL
test_graphql_latency() {
    local operation=$1
    local size=$1
    local iterations=10
    local total_time=0
    
    echo -e "${YELLOW}Test GraphQL - $operation - ${size}KB${NC}"
    
    case $operation in
        "Créer")
            query='mutation { createReservation(input: { client: { nom: "Test" prenom: "User" email: "test@example.com" telephone: "0123456789" } chambre: { id: 1 } dateDebut: "2024-06-01" dateFin: "2024-06-05" preferences: "Vue sur mer" }) { id } }'
            ;;
        "Consulter")
            query='query { reservation(id: 1) { id dateDebut dateFin } }'
            ;;
        "Modifier")
            query='mutation { updateReservation(id: 1, input: { dateDebut: "2024-06-02" dateFin: "2024-06-06" }) { id } }'
            ;;
        "Supprimer")
            query='mutation { deleteReservation(id: 1) }'
            ;;
    esac
    
    for i in $(seq 1 $iterations); do
        start=$(date +%s%N)
        curl -s -X POST "$BASE_URL/graphql" \
            -H "Content-Type: application/json" \
            -d "{\"query\": \"$query\"}" > /dev/null
        end=$(date +%s%N)
        time_ms=$(( (end - start) / 1000000 ))
        total_time=$((total_time + time_ms))
    done
    
    avg_time=$((total_time / iterations))
    echo "$avg_time"
}

# Fonction pour mesurer le débit
test_throughput() {
    local api=$1
    local concurrent=$2
    local duration=30
    
    echo -e "${YELLOW}Test Débit - $api - $concurrent requêtes simultanées${NC}"
    
    case $api in
        "REST")
            # Utiliser Apache Bench si disponible
            if command -v ab &> /dev/null; then
                req_per_sec=$(ab -n $((concurrent * 10)) -c $concurrent "$BASE_URL/api/rest/reservations/1" 2>/dev/null | grep "Requests per second" | awk '{print $4}')
                echo "${req_per_sec:-0}"
            else
                echo "0"
            fi
            ;;
        "GraphQL")
            if command -v ab &> /dev/null; then
                query='{"query":"query { reservations { id } }"}'
                req_per_sec=$(ab -n $((concurrent * 10)) -c $concurrent -p /tmp/graphql_query.txt -T "application/json" "$BASE_URL/graphql" 2>/dev/null | grep "Requests per second" | awk '{print $4}')
                echo "${req_per_sec:-0}"
            else
                echo "0"
            fi
            ;;
        *)
            echo "0"
            ;;
    esac
}

# Fonction pour mesurer les ressources
measure_resources() {
    local api=$1
    local concurrent=$2
    
    echo -e "${YELLOW}Mesure Ressources - $api - $concurrent requêtes${NC}"
    
    # CPU et Mémoire via Docker stats
    docker stats --no-stream --format "{{.CPUPerc}},{{.MemUsage}}" hotel-reservation-api | \
        awk -F',' '{cpu=$1; gsub(/%/, "", cpu); mem=$2; gsub(/MiB.*/, "", mem); print cpu","mem}'
}

# Générer le rapport
generate_report() {
    cat > "$SUMMARY_FILE" << 'EOF'
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

EOF
    echo -e "${GREEN}Rapport généré : $SUMMARY_FILE${NC}"
}

# Menu principal
main() {
    echo -e "${BLUE}Démarrage des tests de performance...${NC}"
    echo ""
    
    # Vérifier que les services sont démarrés
    if ! curl -s "$BASE_URL/actuator/health" > /dev/null; then
        echo -e "${RED}Erreur: L'application n'est pas accessible sur $BASE_URL${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Application accessible${NC}"
    echo ""
    
    # Tests de latence
    echo -e "${BLUE}=== Tests de Latence ===${NC}"
    
    # TODO: Implémenter les tests pour chaque API et chaque taille
    
    # Tests de débit
    echo -e "${BLUE}=== Tests de Débit ===${NC}"
    
    # TODO: Implémenter les tests de débit
    
    # Générer le rapport
    generate_report
    
    echo ""
    echo -e "${GREEN}Tests terminés !${NC}"
    echo -e "Résultats sauvegardés dans : $RESULTS_DIR"
}

main "$@"

