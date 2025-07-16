#!/bin/bash

# Script de démarrage pour Poketter
echo "🚀 Démarrage de Poketter..."

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

# Fonction pour démarrer l'API avec Docker Compose
start_api() {
    echo "📡 Démarrage de l'API avec Docker Compose..."
    cd api
    
    # Détecter la commande Docker Compose
    DOCKER_COMPOSE_CMD=$(get_docker_compose_cmd)
    
    if [ -z "$DOCKER_COMPOSE_CMD" ]; then
        echo "❌ Erreur: Docker Compose n'est pas installé."
        echo "💡 Solutions possibles:"
        echo "   - Si vous utilisez Docker Desktop, Docker Compose est intégré"
        echo "   - Vérifiez que Docker est bien démarré"
        echo "   - Installez Docker Desktop: https://www.docker.com/products/docker-desktop/"
        exit 1
    fi
    
    echo "🔧 Utilisation de: $DOCKER_COMPOSE_CMD"
    
    # Vérifier si .env existe
    if [ ! -f ".env" ]; then
        echo "⚠️  Attention: Fichier .env manquant. Copie de .env.example..."
        cp .env.example .env
        echo "✏️  Veuillez modifier le fichier .env avec vos paramètres"
    fi
    
    # Arrêter les conteneurs existants
    echo "🧹 Arrêt des conteneurs existants..."
    $DOCKER_COMPOSE_CMD down
    
    # Construire et démarrer les conteneurs
    echo "🔧 Construction et démarrage des conteneurs..."
    $DOCKER_COMPOSE_CMD up --build -d
    
    echo "✅ API et base de données démarrées sur http://localhost:3000"
    echo "📊 Base de données PostgreSQL disponible sur localhost:5432"
    cd ..
}

# Fonction pour démarrer Flutter
start_flutter() {
    echo "📱 Démarrage de l'application Flutter..."
    cd front
    
    # Vérifier si flutter est installé
    if ! command -v flutter &> /dev/null; then
        echo "❌ Erreur: Flutter n'est pas installé. Veuillez installer Flutter: https://flutter.dev/"
        exit 1
    fi
    
    # Récupérer les dépendances
    echo "📦 Installation des dépendances Flutter..."
    flutter pub get
    
    # Démarrer l'application
    echo "✅ Lancement de l'application Flutter..."
    flutter run -d chrome
    cd ..
}

# Fonction de nettoyage
cleanup() {
    echo "🧹 Arrêt des services..."
    cd api
    DOCKER_COMPOSE_CMD=$(get_docker_compose_cmd)
    if [ ! -z "$DOCKER_COMPOSE_CMD" ]; then
        $DOCKER_COMPOSE_CMD down
    fi
    cd ..
    exit 0
}

# Capturer le signal d'interruption
trap cleanup SIGINT

# Démarrer les services
start_api
echo "⏳ Attente du démarrage de l'API (10 secondes)..."
sleep 10  # Attendre que l'API et la DB démarrent complètement
start_flutter

# Attendre la fin
wait
