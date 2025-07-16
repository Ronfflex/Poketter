# 🎯 Poketter - Application Flutter avec API

Une application Flutter moderne de découverte de Pokémon avec un système d'authentification complet, construite avec une API Node.js et une base de données PostgreSQL.

## 🚀 Démarrage rapide

### Prérequis
- [Docker](https://docs.docker.com/get-docker/) et [Docker Compose](https://docs.docker.com/compose/install/)
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Git](https://git-scm.com/)

### Installation et lancement
```bash
# Cloner le projet
git clone <repository-url>
cd Poketter

# Démarrer l'application complète
./start.sh
```

C'est tout ! 🎉 L'application se lance automatiquement avec :
- ✅ Base de données PostgreSQL
- ✅ API Node.js avec authentification JWT
- ✅ Application Flutter

## 📱 Fonctionnalités

### Authentification
- 🔐 **Connexion** sécurisée avec JWT
- 📝 **Inscription** avec validation
- 👤 **Profil utilisateur** modifiable
- 🚪 **Déconnexion** sécurisée

### Application Pokémon
- 🔍 **Recherche** de Pokémon
- ⭐ **Favoris** (à venir)
- 📊 **Statistiques** (à venir)
- 🎯 **Recherche avancée** (à venir)

## 🛠️ Scripts utilitaires

### Démarrage et arrêt
```bash
# Démarrer l'application complète
./start.sh

# Arrêter tous les services
./stop.sh

# Arrêter et nettoyer les volumes
./stop.sh --clean
```

## 🏗️ Architecture

### Structure du projet
```
Poketter/
├── api/                    # API Node.js avec Bun
│   ├── src/
│   │   ├── controllers/    # Contrôleurs (auth, user)
│   │   ├── routes/         # Routes Express
│   │   └── utils/          # Middlewares et utilitaires
│   ├── prisma/            # Schéma et migrations
│   ├── docker-compose.yml # Configuration Docker
│   └── .env               # Variables d'environnement
├── front/                 # Application Flutter
│   ├── lib/
│   │   ├── pages/         # Pages de l'application
│   │   ├── services/      # Services API et auth
│   │   └── widgets/       # Composants réutilisables
│   └── pubspec.yaml       # Dépendances Flutter
├── start.sh               # Script de démarrage
└── stop.sh                # Script d'arrêt
```

### Stack technique
- **Frontend** : Flutter (Dart)
- **Backend** : Node.js avec Bun runtime
- **Base de données** : PostgreSQL
- **ORM** : Prisma
- **Authentification** : JWT
- **Containerisation** : Docker & Docker Compose

## 🔧 Configuration

### Variables d'environnement
Le fichier `api/.env` contient :
```env
DATABASE_URL=postgres://admin:adminpwd@postgresdb:5432/db
PORT=3002
JWT_SECRET=your-super-secret-jwt-key-here-please-change-in-production
```

### Endpoints API
- **Base URL** : `http://localhost:3002/api`
- **Auth** : `/auth/login`, `/auth/register`, `/auth/logout`
- **User** : `/user/profile` (GET/PUT)

## 🐳 Docker

### Services
- **postgresdb** : Base de données PostgreSQL (port 5432)
- **api** : API Node.js (port 3002)

### Commandes Docker utiles
```bash
# Voir les logs
docker compose logs -f
# ou
docker-compose logs -f

# Redémarrer un service
docker compose restart api
# ou
docker-compose restart api

# Reconstruire les conteneurs
docker compose up --build
# ou
docker-compose up --build

# Nettoyer les volumes
docker compose down -v
# ou
docker-compose down -v
```

## 🔒 Sécurité

- **JWT** : Tokens sécurisés avec expiration
- **Bcrypt** : Hachage des mots de passe
- **Validation** : Contrôles côté client et serveur
- **CORS** : Configuration sécurisée
- **Middleware** : Authentification sur les routes protégées

## 📖 Documentation

- [API Implementation](./API_IMPLEMENTATION.md) - Documentation détaillée de l'implémentation
- [Frontend Guide](./front/README.md) - Guide de l'application Flutter
- [Backend Guide](./api/README.md) - Guide de l'API

## 🤝 Contribution

1. Fork le projet
2. Créer une branche (`git checkout -b feature/nouvelle-fonctionnalite`)
3. Commit (`git commit -m 'Ajout d'une nouvelle fonctionnalité'`)
4. Push (`git push origin feature/nouvelle-fonctionnalite`)
5. Ouvrir une Pull Request

## 📝 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 🆘 Support

En cas de problème :
1. Vérifier les logs avec `docker compose logs` ou `docker-compose logs`
2. Redémarrer avec `./stop.sh && ./start.sh`
3. Ouvrir une issue sur GitHub

---

**Développé avec ❤️ par l'équipe Poketter**
