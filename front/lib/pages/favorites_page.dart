import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../services/api_service.dart';
import '../services/pokemon_service.dart';
import '../widgets/loading_widget.dart';
import '../widgets/pokemon_card.dart';
import 'pokemon_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Pokemon> _favoritePokemon = [];
  bool _isLoading = false;
  final PokemonService _pokemonService = PokemonService();

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get liked Pokemon from API
      final likesResult = await ApiService.getLikes();

      if (likesResult.success && likesResult.data != null) {
        final List<Pokemon> favorites = [];

        // For each like, fetch the Pokemon details
        for (final like in likesResult.data!) {
          try {
            final pokemon = await _pokemonService.getPokemon(like.pokemonId);
            favorites.add(pokemon);
          } catch (e) {
            print('Error loading favorite pokemon ${like.pokemonId}: $e');
          }
        }

        setState(() {
          _favoritePokemon = favorites;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                likesResult.message ?? 'Erreur lors du chargement des favoris',
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des favoris: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        title: const Text('Mes Favoris'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadFavorites,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _favoritePokemon.isEmpty
          ? _buildEmptyState()
          : _buildFavoritesList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 120, color: Colors.grey.shade400),
          const SizedBox(height: 24),
          Text(
            'Aucun favori',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ajoutez des Pokémon à vos favoris\npour les retrouver ici !',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList() {
    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _favoritePokemon.length,
        itemBuilder: (context, index) {
          final pokemon = _favoritePokemon[index];
          return PokemonCard(
            pokemon: PokemonListItem(
              name: pokemon.name,
              url: '',
              id: pokemon.id,
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PokemonDetailPage(pokemon: pokemon),
                ),
              );
              // Refresh favorites when returning from detail page
              _loadFavorites();
            },
          );
        },
      ),
    );
  }
}
