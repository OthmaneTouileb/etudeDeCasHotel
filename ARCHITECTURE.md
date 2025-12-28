# Architecture du Projet

## Vue d'Ensemble

Ce projet implémente une plateforme de réservation d'hôtels avec quatre types d'APIs différents pour permettre une comparaison complète des technologies.

## Architecture en Couches

```
┌─────────────────────────────────────────────────────────┐
│                    Client Web                            │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐│
│  │   REST   │  │ GraphQL  │  │   SOAP   │  │   gRPC   ││
│  │  Client  │  │  Client  │  │  Client  │  │  Client  ││
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘│
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│              Tomcat + Spring IOC Container              │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │            Web Layer (Controllers)                │  │
│  │  ┌──────────────┐  ┌──────────────┐             │  │
│  │  │ Reservation  │  │ Reservation   │             │  │
│  │  │  REST Ctrl  │  │ GraphQL Ctrl  │             │  │
│  │  └──────────────┘  └──────────────┘             │  │
│  │  ┌──────────────┐  ┌──────────────┐             │  │
│  │  │ Reservation  │  │ Reservation  │             │  │
│  │  │  SOAP Svc    │  │  gRPC Svc     │             │  │
│  │  └──────────────┘  └──────────────┘             │  │
│  └──────────────────────────────────────────────────┘  │
│                        ↓                                │
│  ┌──────────────────────────────────────────────────┐  │
│  │         Business Layer (Services)                 │  │
│  │  ┌────────────────────────────────────────────┐  │  │
│  │  │      ReservationService Interface          │  │  │
│  │  │  ┌──────────────────────────────────────┐  │  │  │
│  │  │  │   ReservationServiceImpl            │  │  │  │
│  │  │  │   (Logique métier)                   │  │  │  │
│  │  │  └──────────────────────────────────────┘  │  │  │
│  │  └────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────┘  │
│                        ↓                                │
│  ┌──────────────────────────────────────────────────┐  │
│  │         DAO Layer (Repositories)                  │  │
│  │  ┌────────────────────────────────────────────┐  │  │
│  │  │      ReservationRepository                 │  │  │
│  │  │      ClientRepository                      │  │  │
│  │  │      ChambreRepository                     │  │  │
│  │  │                                            │  │  │
│  │  │      Spring Data JPA                       │  │  │
│  │  │      ↓                                     │  │  │
│  │  │      JPA | Hibernate | JDBC               │  │  │
│  │  └────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│                    DATABASE                              │
│              (MySQL / PostgreSQL)                        │
└─────────────────────────────────────────────────────────┘
```

## Composants Principaux

### 1. Web Layer (Couche Présentation)

#### ReservationRestController (REST)
- **Endpoint** : `/api/rest/reservations`
- **Méthodes HTTP** : GET, POST, PUT, DELETE
- **Format** : JSON
- **Documentation** : Swagger/OpenAPI

#### ReservationGraphQLController (GraphQL)
- **Endpoint** : `/graphql`
- **Opérations** : Queries et Mutations
- **Format** : GraphQL
- **Schéma** : `schema.graphqls`

#### ReservationSoapService (SOAP)
- **Endpoint** : `/soap`
- **Format** : XML/SOAP
- **WSDL** : `/soap/reservations.wsdl`
- **Schéma** : `reservation.xsd`

#### ReservationGrpcService (gRPC)
- **Port** : `9090`
- **Format** : Protocol Buffers
- **Proto** : `reservation.proto`

### 2. Business Layer (Couche Métier)

#### ReservationService
Interface définissant les opérations métier :
- `createReservation(ReservationDTO)` : Créer une réservation
- `getReservationById(Long)` : Consulter une réservation
- `getAllReservations()` : Lister toutes les réservations
- `updateReservation(Long, ReservationDTO)` : Modifier une réservation
- `deleteReservation(Long)` : Supprimer une réservation

#### ReservationServiceImpl
Implémentation de la logique métier :
- Validation des données
- Gestion des entités Client et Chambre
- Transformation DTO ↔ Entity
- Gestion des transactions

### 3. DAO Layer (Couche Accès aux Données)

#### Repositories
- **ReservationRepository** : Accès aux réservations
- **ClientRepository** : Accès aux clients
- **ChambreRepository** : Accès aux chambres

Utilise Spring Data JPA pour simplifier l'accès aux données.

### 4. Data Models

#### Entités JPA
- **Client** : Informations du client
- **Chambre** : Informations de la chambre
- **Reservation** : Réservation avec références aux entités

#### DTOs (Data Transfer Objects)
- **ClientDTO** : Transfert de données client
- **ChambreDTO** : Transfert de données chambre
- **ReservationDTO** : Transfert de données réservation

#### Mappers
- **ReservationMapper** : Conversion Entity ↔ DTO (MapStruct)

## Flux de Données

### Création d'une Réservation (REST)

```
1. Client → POST /api/rest/reservations
   ↓
2. ReservationRestController.createReservation()
   ↓
3. ReservationServiceImpl.createReservation()
   ↓
4. Validation et conversion DTO → Entity
   ↓
5. ReservationRepository.save()
   ↓
6. JPA/Hibernate → Database
   ↓
7. Entity → DTO (via Mapper)
   ↓
8. Response JSON → Client
```

### Consultation d'une Réservation (GraphQL)

```
1. Client → POST /graphql (Query)
   ↓
2. ReservationGraphQLController.reservation()
   ↓
3. ReservationServiceImpl.getReservationById()
   ↓
4. ReservationRepository.findById()
   ↓
5. JPA/Hibernate → Database
   ↓
6. Entity → DTO (via Mapper)
   ↓
7. GraphQL Engine → Response JSON
   ↓
8. Client reçoit uniquement les champs demandés
```

## Technologies Utilisées

### Framework
- **Spring Boot 3.2.0** : Framework principal
- **Spring Data JPA** : Accès aux données
- **Spring Web Services** : Support SOAP
- **Spring GraphQL** : Support GraphQL
- **Spring gRPC** : Support gRPC

### Persistence
- **JPA/Hibernate** : ORM
- **MySQL/PostgreSQL** : Base de données

### Mapping
- **MapStruct** : Mapping DTO/Entity

### Documentation
- **OpenAPI/Swagger** : Documentation REST
- **GraphQL Schema** : Documentation GraphQL
- **WSDL/XSD** : Documentation SOAP
- **Proto** : Documentation gRPC

## Points d'Extension

### Sécurité
- Ajouter Spring Security
- Implémenter OAuth2/JWT
- Activer HTTPS/TLS

### Monitoring
- Intégrer Spring Boot Actuator
- Configurer Prometheus
- Créer des dashboards Grafana

### Cache
- Ajouter Redis pour le cache
- Implémenter le cache au niveau service

### Validation
- Ajouter des validations Bean Validation
- Validation personnalisée pour les dates

### Gestion d'Erreurs
- Créer des exceptions personnalisées
- Handler global pour les erreurs
- Messages d'erreur standardisés

## Configuration

### application.properties
- Configuration de la base de données
- Configuration des ports
- Configuration GraphQL
- Configuration SOAP
- Configuration gRPC

### Build Configuration
- **pom.xml** : Dépendances Maven
- **protobuf-maven-plugin** : Génération des classes gRPC
- **mapstruct-processor** : Génération des mappers

## Tests

Voir `TESTING.md` pour les détails sur les tests de performance et de charge.

