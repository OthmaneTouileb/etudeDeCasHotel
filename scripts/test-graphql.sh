#!/bin/bash

# Script de test pour l'API GraphQL

BASE_URL="http://localhost:8080/graphql"

echo "=== Test de l'API GraphQL ==="

# Test 1: Créer une réservation
echo -e "\n1. Création d'une réservation..."
CREATE_MUTATION='mutation {
  createReservation(input: {
    client: {
      nom: "Test"
      prenom: "User"
      email: "test.user@example.com"
      telephone: "0123456789"
    }
    chambre: {
      id: 1
    }
    dateDebut: "2024-06-01"
    dateFin: "2024-06-05"
    preferences: "Vue sur mer"
  }) {
    id
    dateDebut
    dateFin
    client {
      nom
      prenom
    }
  }
}'

RESPONSE=$(curl -s -X POST "$BASE_URL" \
  -H "Content-Type: application/json" \
  -d "{\"query\": \"$CREATE_MUTATION\"}")

echo "$RESPONSE" | jq '.'

RESERVATION_ID=$(echo "$RESPONSE" | jq -r '.data.createReservation.id')
echo "ID de la réservation créée: $RESERVATION_ID"

# Test 2: Consulter une réservation
echo -e "\n2. Consultation de la réservation..."
GET_QUERY="query {
  reservation(id: $RESERVATION_ID) {
    id
    dateDebut
    dateFin
    preferences
    client {
      nom
      prenom
      email
    }
    chambre {
      type
      prix
    }
  }
}"

curl -s -X POST "$BASE_URL" \
  -H "Content-Type: application/json" \
  -d "{\"query\": \"$GET_QUERY\"}" | jq '.'

# Test 3: Modifier une réservation
echo -e "\n3. Modification de la réservation..."
UPDATE_MUTATION="mutation {
  updateReservation(id: $RESERVATION_ID, input: {
    dateDebut: \"2024-06-02\"
    dateFin: \"2024-06-06\"
    preferences: \"Vue sur mer, petit-déjeuner inclus\"
  }) {
    id
    dateDebut
    dateFin
  }
}"

curl -s -X POST "$BASE_URL" \
  -H "Content-Type: application/json" \
  -d "{\"query\": \"$UPDATE_MUTATION\"}" | jq '.'

# Test 4: Lister toutes les réservations
echo -e "\n4. Liste de toutes les réservations..."
LIST_QUERY='query {
  reservations {
    id
    dateDebut
    dateFin
    client {
      nom
      prenom
    }
  }
}'

curl -s -X POST "$BASE_URL" \
  -H "Content-Type: application/json" \
  -d "{\"query\": \"$LIST_QUERY\"}" | jq '.'

# Test 5: Supprimer une réservation
echo -e "\n5. Suppression de la réservation..."
DELETE_MUTATION="mutation {
  deleteReservation(id: $RESERVATION_ID)
}"

curl -s -X POST "$BASE_URL" \
  -H "Content-Type: application/json" \
  -d "{\"query\": \"$DELETE_MUTATION\"}" | jq '.'

echo -e "\n=== Tests terminés ==="

