import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/pokemon.dart';
import '../services/pokemon_service.dart';
import '../widgets/loading_widget.dart';
import 'pokemon_detail_page.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PokemonService _pokemonService = PokemonService();

  List<Pokemon> _pokemonList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadPokemonData();
  }

  Future<void> _loadPokemonData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pokemonListItems = await _pokemonService.getPokemonList(limit: 150);
      final List<Pokemon> pokemonDetails = [];

      for (var item in pokemonListItems) {
        try {
          final pokemon = await _pokemonService.getPokemon(item.id);
          pokemonDetails.add(pokemon);
        } catch (e) {
          print('Error loading pokemon ${item.id}: $e');
        }
      }

      setState(() {
        _pokemonList = pokemonDetails;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        title: const Text('Statistiques'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Plus forts'),
            Tab(text: 'Plus grands'),
            Tab(text: 'Plus lourds'),
            Tab(text: 'Plus rapides'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPokemonData,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildStrongestPokemon(),
                _buildTallestPokemon(),
                _buildHeaviestPokemon(),
                _buildFastestPokemon(),
              ],
            ),
    );
  }

  Widget _buildStrongestPokemon() {
    final sortedPokemon = _pokemonList.toList()
      ..sort((a, b) {
        final aTotal = a.stats.fold(0, (sum, stat) => sum + stat.baseStat);
        final bTotal = b.stats.fold(0, (sum, stat) => sum + stat.baseStat);
        return bTotal.compareTo(aTotal);
      });

    return _buildRankingList(
      pokemon: sortedPokemon,
      title: 'Pokémon les plus forts',
      subtitle: 'Classés par stats totales',
      icon: Icons.fitness_center,
      color: Colors.red,
      getValue: (pokemon) {
        final total = pokemon.stats.fold(0, (sum, stat) => sum + stat.baseStat);
        return '$total pts';
      },
    );
  }

  Widget _buildTallestPokemon() {
    final sortedPokemon = _pokemonList.toList()
      ..sort((a, b) => b.height.compareTo(a.height));

    return _buildRankingList(
      pokemon: sortedPokemon,
      title: 'Pokémon les plus grands',
      subtitle: 'Classés par taille',
      icon: Icons.height,
      color: Colors.blue,
      getValue: (pokemon) => '${(pokemon.height / 10).toStringAsFixed(1)}m',
    );
  }

  Widget _buildHeaviestPokemon() {
    final sortedPokemon = _pokemonList.toList()
      ..sort((a, b) => b.weight.compareTo(a.weight));

    return _buildRankingList(
      pokemon: sortedPokemon,
      title: 'Pokémon les plus lourds',
      subtitle: 'Classés par poids',
      icon: Icons.monitor_weight,
      color: Colors.orange,
      getValue: (pokemon) => '${(pokemon.weight / 10).toStringAsFixed(1)}kg',
    );
  }

  Widget _buildFastestPokemon() {
    final sortedPokemon = _pokemonList.toList()
      ..sort((a, b) {
        final aSpeed = a.stats
            .firstWhere((stat) => stat.name == 'speed')
            .baseStat;
        final bSpeed = b.stats
            .firstWhere((stat) => stat.name == 'speed')
            .baseStat;
        return bSpeed.compareTo(aSpeed);
      });

    return _buildRankingList(
      pokemon: sortedPokemon,
      title: 'Pokémon les plus rapides',
      subtitle: 'Classés par vitesse',
      icon: Icons.speed,
      color: Colors.green,
      getValue: (pokemon) {
        final speed = pokemon.stats
            .firstWhere((stat) => stat.name == 'speed')
            .baseStat;
        return '$speed pts';
      },
    );
  }

  Widget _buildRankingList({
    required List<Pokemon> pokemon,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String Function(Pokemon) getValue,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: pokemon.length,
            itemBuilder: (context, index) {
              final poke = pokemon[index];
              return _buildRankingItem(
                pokemon: poke,
                rank: index + 1,
                value: getValue(poke),
                color: color,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRankingItem({
    required Pokemon pokemon,
    required int rank,
    required String value,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PokemonDetailPage(pokemon: pokemon),
            ),
          );
        },
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getRankColor(rank),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Hero(
              tag: 'pokemon-${pokemon.id}',
              child: CachedNetworkImage(
                imageUrl: pokemon.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.contain,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(
                  Icons.catching_pokemon,
                  size: 30,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ],
        ),
        title: Text(
          pokemon.name.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          'ID: ${pokemon.id} • Types: ${pokemon.types.join(', ')}',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber; // Or
      case 2:
        return Colors.grey; // Argent
      case 3:
        return Colors.brown; // Bronze
      default:
        return Colors.blue;
    }
  }
}
