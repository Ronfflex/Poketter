import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/pokemon_detail_page.dart';
import '../pages/profile_page.dart';
import '../pages/login_page.dart';
import '../pages/favorites_page.dart';
import '../pages/advanced_search_page.dart';
import '../pages/stats_page.dart';
import '../providers/pokemon_provider.dart';
import '../widgets/pokemon_card.dart';

class PokemonListPage extends StatefulWidget {
  const PokemonListPage({super.key});

  @override
  State<PokemonListPage> createState() => _PokemonListPageState();
}

class _PokemonListPageState extends State<PokemonListPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isUserLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PokemonProvider>(context, listen: false);
      provider.loadPokemonList();
      provider.loadPokemonTypes();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final provider = Provider.of<PokemonProvider>(context, listen: false);
        if (!provider.isLoadingMore &&
            provider.selectedType.isEmpty &&
            !provider.isSearchMode) {
          provider.loadPokemonList(loadMore: true);
        }
      }
    });
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    setState(() {
      _isUserLoggedIn = username != null && username.isNotEmpty;
    });
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    ).then((_) {
      // Vérifier le statut de connexion après retour de la page de login
      _checkLoginStatus();
    });
  }

  void _navigateToFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FavoritesPage()),
    );
  }

  void _navigateToAdvancedSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdvancedSearchPage()),
    );
  }

  void _navigateToStats() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StatsPage()),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Pokédex',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          // Bouton de profil/connexion avec menu
          PopupMenuButton<String>(
            icon: Icon(_isUserLoggedIn ? Icons.person : Icons.login),
            onSelected: (String value) {
              switch (value) {
                case 'profile':
                  _navigateToProfile();
                  break;
                case 'login':
                  _navigateToLogin();
                  break;
                case 'favorites':
                  _navigateToFavorites();
                  break;
                case 'search':
                  _navigateToAdvancedSearch();
                  break;
                case 'stats':
                  _navigateToStats();
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              if (_isUserLoggedIn) {
                return [
                  const PopupMenuItem(
                    value: 'profile',
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Mon profil'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'favorites',
                    child: ListTile(
                      leading: Icon(Icons.favorite),
                      title: Text('Mes favoris'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'search',
                    child: ListTile(
                      leading: Icon(Icons.search),
                      title: Text('Recherche avancée'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'stats',
                    child: ListTile(
                      leading: Icon(Icons.bar_chart),
                      title: Text('Statistiques'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ];
              } else {
                return [
                  const PopupMenuItem(
                    value: 'login',
                    child: ListTile(
                      leading: Icon(Icons.login),
                      title: Text('Se connecter'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ];
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildSelectedTypeChip(),
          Expanded(child: _buildPokemonGrid()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Search Pokémon by name or ID...',
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (value) {
          Provider.of<PokemonProvider>(
            context,
            listen: false,
          ).setSearchQuery(value);
        },
      ),
    );
  }

  Widget _buildSelectedTypeChip() {
    return Consumer<PokemonProvider>(
      builder: (context, provider, child) {
        if (provider.selectedType.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                'Filter: ',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Chip(
                label: Text(_capitalize(provider.selectedType)),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => provider.clearTypeFilter(),
                backgroundColor: Colors.blue.shade100,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPokemonGrid() {
    return Consumer<PokemonProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading || provider.isSearching) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  provider.isSearching ? 'Searching...' : 'Loading...',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        if (provider.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  provider.isSearchMode
                      ? 'Search failed'
                      : 'Oops! Something went wrong',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.error,
                  style: TextStyle(color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _searchController.clear();
                    provider.setSearchQuery('');
                    if (!provider.isSearchMode) {
                      provider.loadPokemonList();
                    }
                  },
                  child: Text(provider.isSearchMode ? 'Clear Search' : 'Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.pokemonList.isEmpty) {
          String emptyMessage = 'No Pokémon found';
          String emptySubtitle = 'Try adjusting your search or filters';

          if (provider.searchQuery.isNotEmpty) {
            emptyMessage = 'No Pokémon found for "${provider.searchQuery}"';
            emptySubtitle =
                'Try searching by exact name or ID (e.g., "pikachu" or "25")';
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  emptyMessage,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  emptySubtitle,
                  style: TextStyle(color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount:
              provider.pokemonList.length +
              (provider.isLoadingMore && !provider.isSearchMode ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= provider.pokemonList.length) {
              return const Center(child: CircularProgressIndicator());
            }

            final pokemon = provider.pokemonList[index];
            return PokemonCard(
              pokemon: pokemon,
              onTap: () => _navigateToPokemonDetail(pokemon.id),
            );
          },
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<PokemonProvider>(
          builder: (context, provider, child) {
            return AlertDialog(
              title: const Text('Filter by Type'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: provider.pokemonTypes.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: provider.pokemonTypes.length,
                        itemBuilder: (context, index) {
                          final type = provider.pokemonTypes[index];
                          return ListTile(
                            title: Text(_capitalize(type)),
                            onTap: () {
                              provider.setTypeFilter(type);
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    provider.clearTypeFilter();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Clear Filter'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _navigateToPokemonDetail(int pokemonId) async {
    try {
      final provider = Provider.of<PokemonProvider>(context, listen: false);
      final pokemon = await provider.getPokemonDetails(pokemonId);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PokemonDetailPage(pokemon: pokemon),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading Pokemon details: $e')),
        );
      }
    }
  }

  String _capitalize(String text) {
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
