#!/bin/bash

# Script de test pour l'API REST

BASE_URL="http://localhost:8080/api/rest/reservations"

echo "=== Test de l'API REST ==="

# Test 1: Créer une réservation
echo -e "\n1. Création d'une réservation..."
RESPONSE=$(curl -s -X POST "$BASE_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "client": {
      "nom": "Test",
      "prenom": "User",
      "email": "test.user@example.com",
      "telephone": "0123456789"
    },
    "chambre": {
      "id": 1,
      "type": "double",
      "prix": 120.0,
      "disponible": true
    },
    "dateDebut": "2024-06-01",
    "dateFin": "2024-06-05",
    "preferences": "Vue sur mer"
  }')

echo "$RESPONSE" | jq '.'

RESERVATION_ID=$(echo "$RESPONSE" | jq -r '.id')
echo "ID de la réservation créée: $RESERVATION_ID"

# Test 2: Consulter une réservation
echo -e "\n2. Consultation de la réservation..."
curl -s -X GET "$BASE_URL/$RESERVATION_ID" | jq '.'

# Test 3: Modifier une réservation
echo -e "\n3. Modification de la réservation..."
curl -s -X PUT "$BASE_URL/$RESERVATION_ID" \
  -H "Content-Type: application/json" \
  -d '{
    "dateDebut": "2024-06-02",
    "dateFin": "2024-06-06",
    "preferences": "Vue sur mer, petit-déjeuner inclus"
  }' | jq '.'

# Test 4: Lister toutes les réservations
echo -e "\n4. Liste de toutes les réservations..."
curl -s -X GET "$BASE_URL" | jq '.'

# Test 5: Supprimer une réservation
echo -e "\n5. Suppression de la réservation..."
curl -s -X DELETE "$BASE_URL/$RESERVATION_ID"
echo -e "\nRéservation supprimée avec succès"

echo -e "\n=== Tests terminés ==="

