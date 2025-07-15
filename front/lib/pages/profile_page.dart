import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _username = 'Dresseur Pokémon';
  String _loginDate = '';
  int _pokemonViewed = 0;
  int _favoritesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Dresseur Pokémon';
      _loginDate = prefs.getString('login_date') ?? DateTime.now().toString();
      _pokemonViewed = prefs.getInt('pokemon_viewed') ?? 0;
      _favoritesCount = prefs.getInt('favorites_count') ?? 0;
    });
  }

  Future<void> _saveUsername(String newUsername) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', newUsername);
    setState(() {
      _username = newUsername;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        title: const Text('Mon Profil'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildStatsSection(),
            const SizedBox(height: 24),
            _buildSettingsSection(),
            const SizedBox(height: 24),
            _buildAchievementsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.red.shade600,
            child: const Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            _username,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Membre depuis le ${_formatDate(_loginDate)}',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showEditUsernameDialog,
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Modifier le pseudo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistiques',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Pokémon vus',
                  _pokemonViewed.toString(),
                  Icons.visibility,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Favoris',
                  _favoritesCount.toString(),
                  Icons.favorite,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Niveau',
                  _calculateLevel().toString(),
                  Icons.stars,
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Jours actifs',
                  _getDaysSinceLogin().toString(),
                  Icons.calendar_today,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Paramètres',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingItem(
            'Notifications',
            'Recevoir des notifications',
            Icons.notifications,
            true,
          ),
          _buildSettingItem(
            'Mode sombre',
            'Activer le thème sombre',
            Icons.dark_mode,
            false,
          ),
          _buildSettingItem(
            'Synchronisation',
            'Synchroniser avec le cloud',
            Icons.cloud_sync,
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    String subtitle,
    IconData icon,
    bool value,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.red.shade600),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: (bool newValue) {
          // TODO: Implement settings logic
        },
        activeColor: Colors.red.shade600,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildAchievementsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trophées',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildAchievementBadge(
                'Premier Pokémon',
                Icons.star,
                Colors.amber,
              ),
              _buildAchievementBadge(
                'Collectionneur',
                Icons.catching_pokemon,
                Colors.blue,
              ),
              _buildAchievementBadge(
                'Explorateur',
                Icons.explore,
                Colors.green,
              ),
              _buildAchievementBadge(
                'Maître',
                Icons.emoji_events,
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditUsernameDialog() {
    final TextEditingController controller = TextEditingController(
      text: _username,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modifier le pseudo'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nouveau pseudo',
              hintText: 'Entrez votre nouveau pseudo',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _saveUsername(controller.text);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sauvegarder'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Aujourd\'hui';
    }
  }

  int _calculateLevel() {
    return (_pokemonViewed / 10).floor() + 1;
  }

  int _getDaysSinceLogin() {
    try {
      final loginDate = DateTime.parse(_loginDate);
      final now = DateTime.now();
      return now.difference(loginDate).inDays;
    } catch (e) {
      return 0;
    }
  }
}
