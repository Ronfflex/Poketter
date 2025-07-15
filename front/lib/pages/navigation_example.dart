import 'package:flutter/material.dart';

// Import des nouvelles pages
import 'favorites_page.dart';
import 'advanced_search_page.dart';
import 'stats_page.dart';
import 'profile_page.dart';

// Exemple d'utilisation des nouvelles pages
class NavigationExample extends StatelessWidget {
  const NavigationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation vers les nouvelles pages'),
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Nouvelles pages disponibles :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Bouton vers la page des favoris
            _buildNavigationButton(
              context,
              title: 'Mes Favoris',
              subtitle: 'Voir tous vos Pokémon favoris',
              icon: Icons.favorite,
              color: Colors.red,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesPage()),
              ),
            ),

            const SizedBox(height: 12),

            // Bouton vers la page de recherche avancée
            _buildNavigationButton(
              context,
              title: 'Recherche avancée',
              subtitle: 'Rechercher avec des filtres détaillés',
              icon: Icons.search,
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdvancedSearchPage(),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Bouton vers la page des statistiques
            _buildNavigationButton(
              context,
              title: 'Statistiques',
              subtitle: 'Classements et records',
              icon: Icons.bar_chart,
              color: Colors.green,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatsPage()),
              ),
            ),

            const SizedBox(height: 12),

            // Bouton vers la page de profil
            _buildNavigationButton(
              context,
              title: 'Mon Profil',
              subtitle: 'Gérer vos informations personnelles',
              icon: Icons.person,
              color: Colors.purple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}

// Widget pour intégrer dans une BottomNavigationBar
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    // const PokemonListPage(), // Votre page existante
    const Center(child: Text('Liste des Pokémon')), // Placeholder
    const FavoritesPage(),
    const AdvancedSearchPage(),
    const StatsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red.shade600,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.catching_pokemon),
            label: 'Pokémon',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoris'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Recherche'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
