#!/bin/bash

# Script d'arrêt pour Poketter
echo "🛑 Arrêt de Poketter..."

# Vérifier si nous sommes dans le bon répertoire
if [ ! -d "api" ] || [ ! -d "front" ]; then
    echo "❌ Erreur: Ce script doit être exécuté depuis la racine du projet Poketter"
    exit 1
fi

# Fonction pour détecter la commande Docker Compose
get_docker_compose_cmd() {
    if command -v docker-compose &> /dev/null; then
        echo "docker-compose"
    elif docker compose version &> /dev/null; then
        echo "docker compose"
    else
        echo ""
    fi
}

# Arrêter les conteneurs Docker
echo "🧹 Arrêt des conteneurs Docker..."
cd api

DOCKER_COMPOSE_CMD=$(get_docker_compose_cmd)

if [ -z "$DOCKER_COMPOSE_CMD" ]; then
    echo "❌ Erreur: Docker Compose n'est pas disponible"
    exit 1
fi

echo "🔧 Utilisation de: $DOCKER_COMPOSE_CMD"
$DOCKER_COMPOSE_CMD down

# Supprimer les volumes si demandé
if [ "$1" = "--clean" ]; then
    echo "🗑️  Suppression des volumes Docker..."
    $DOCKER_COMPOSE_CMD down -v
    docker system prune -f
fi

cd ..
echo "✅ Poketter arrêté avec succès"
