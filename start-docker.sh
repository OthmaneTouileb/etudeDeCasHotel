#!/bin/bash

# Script de démarrage Docker Compose
# Usage: ./start-docker.sh [build|up|down|logs|restart]

case "$1" in
    build)
        echo "🔨 Construction des images Docker..."
        docker-compose build
        ;;
    up)
        echo "🚀 Démarrage de tous les services..."
        docker-compose up -d
        echo "✅ Services démarrés!"
        echo ""
        echo "📋 Accès aux services:"
        echo "   - REST API: http://localhost:8080/api/rest/reservations"
        echo "   - GraphQL: http://localhost:8080/graphql"
        echo "   - SOAP WSDL: http://localhost:8080/soap/reservations.wsdl"
        echo "   - Swagger UI: http://localhost:8080/swagger-ui.html"
        echo "   - gRPC: localhost:9090"
        echo "   - Prometheus: http://localhost:9091"
        echo "   - Grafana: http://localhost:3000 (admin/admin)"
        ;;
    down)
        echo "🛑 Arrêt de tous les services..."
        docker-compose down
        ;;
    logs)
        echo "📄 Affichage des logs..."
        docker-compose logs -f
        ;;
    restart)
        echo "🔄 Redémarrage des services..."
        docker-compose restart
        ;;
    *)
        echo "Usage: $0 {build|up|down|logs|restart}"
        echo ""
        echo "Commandes:"
        echo "  build    - Construire les images Docker"
        echo "  up       - Démarrer tous les services"
        echo "  down     - Arrêter tous les services"
        echo "  logs     - Afficher les logs"
        echo "  restart  - Redémarrer les services"
        exit 1
        ;;
esac

