# Script PowerShell de démarrage Docker Compose
# Usage: .\start-docker.ps1 [build|up|down|logs|restart]

param(
    [Parameter(Position=0)]
    [ValidateSet("build", "up", "down", "logs", "restart")]
    [string]$Action = "up"
)

switch ($Action) {
    "build" {
        Write-Host "🔨 Construction des images Docker..." -ForegroundColor Cyan
        docker-compose build
    }
    "up" {
        Write-Host "🚀 Démarrage de tous les services..." -ForegroundColor Green
        docker-compose up -d
        Write-Host "✅ Services démarrés!" -ForegroundColor Green
        Write-Host ""
        Write-Host "📋 Accès aux services:" -ForegroundColor Yellow
        Write-Host "   - REST API: http://localhost:8080/api/rest/reservations"
        Write-Host "   - GraphQL: http://localhost:8080/graphql"
        Write-Host "   - SOAP WSDL: http://localhost:8080/soap/reservations.wsdl"
        Write-Host "   - Swagger UI: http://localhost:8080/swagger-ui.html"
        Write-Host "   - gRPC: localhost:9090"
        Write-Host "   - Prometheus: http://localhost:9091"
        Write-Host "   - Grafana: http://localhost:3000 (admin/admin)"
    }
    "down" {
        Write-Host "🛑 Arrêt de tous les services..." -ForegroundColor Red
        docker-compose down
    }
    "logs" {
        Write-Host "📄 Affichage des logs..." -ForegroundColor Cyan
        docker-compose logs -f
    }
    "restart" {
        Write-Host "🔄 Redémarrage des services..." -ForegroundColor Yellow
        docker-compose restart
    }
}

