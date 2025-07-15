import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/pokemon.dart';
import '../services/pokemon_service.dart';
import '../widgets/loading_widget.dart';
import 'pokemon_detail_page.dart';

class AdvancedSearchPage extends StatefulWidget {
  const AdvancedSearchPage({super.key});

  @override
  State<AdvancedSearchPage> createState() => _AdvancedSearchPageState();
}

class _AdvancedSearchPageState extends State<AdvancedSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final PokemonService _pokemonService = PokemonService();

  List<Pokemon> _searchResults = [];
  List<String> _pokemonTypes = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  String? _selectedType;
  RangeValues _heightRange = const RangeValues(0, 100);
  RangeValues _weightRange = const RangeValues(0, 1000);
  int _minStats = 0;
  int _maxStats = 800;

  @override
  void initState() {
    super.initState();
    _loadPokemonTypes();
  }

  Future<void> _loadPokemonTypes() async {
    try {
      final types = await _pokemonService.getPokemonTypes();
      setState(() {
        _pokemonTypes = types;
      });
    } catch (e) {
      print('Error loading types: $e');
    }
  }

  Future<void> _searchPokemon() async {
    if (_searchController.text.isEmpty && _selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un nom ou sélectionner un type'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      List<Pokemon> results = [];

      if (_searchController.text.isNotEmpty) {
        // Recherche par nom
        try {
          final pokemon = await _pokemonService.getPokemonByName(
            _searchController.text,
          );
          results = [pokemon];
        } catch (e) {
          // Si pas trouvé par nom exact, on peut implémenter une recherche floue
          results = [];
        }
      } else if (_selectedType != null) {
        // Recherche par type
        final pokemonList = await _pokemonService.getPokemonByType(
          _selectedType!,
        );

        // Charger les détails des premiers 20 Pokémon
        for (int i = 0; i < pokemonList.length && i < 20; i++) {
          try {
            final pokemon = await _pokemonService.getPokemon(pokemonList[i].id);
            results.add(pokemon);
          } catch (e) {
            print('Error loading pokemon ${pokemonList[i].id}: $e');
          }
        }
      }

      // Appliquer les filtres
      final filteredResults = results.where((pokemon) {
        // Filtre par taille
        final height =
            pokemon.height / 10.0; // Convertir de décimètres en mètres
        if (height < _heightRange.start || height > _heightRange.end) {
          return false;
        }

        // Filtre par poids
        final weight = pokemon.weight / 10.0; // Convertir de hectogrammes en kg
        if (weight < _weightRange.start || weight > _weightRange.end) {
          return false;
        }

        // Filtre par stats totales
        final totalStats = pokemon.stats.fold(
          0,
          (sum, stat) => sum + stat.baseStat,
        );
        if (totalStats < _minStats || totalStats > _maxStats) {
          return false;
        }

        return true;
      }).toList();

      setState(() {
        _searchResults = filteredResults;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la recherche: $e')),
        );
      }
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchResults.clear();
      _hasSearched = false;
      _selectedType = null;
      _heightRange = const RangeValues(0, 100);
      _weightRange = const RangeValues(0, 1000);
      _minStats = 0;
      _maxStats = 800;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        title: const Text('Recherche avancée'),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.clear), onPressed: _clearSearch),
        ],
      ),
      body: Column(
        children: [
          _buildSearchFilters(),
          const SizedBox(height: 16),
          _buildSearchButton(),
          const SizedBox(height: 16),
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildSearchFilters() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
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
            'Filtres de recherche',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Recherche par nom
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Nom du Pokémon',
              hintText: 'Ex: Pikachu',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 16),

          // Sélection du type
          DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: InputDecoration(
              labelText: 'Type',
              prefixIcon: const Icon(Icons.category),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('Tous les types'),
              ),
              ..._pokemonTypes.map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.toUpperCase()),
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedType = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // Filtre par taille
          const Text(
            'Taille (mètres)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          RangeSlider(
            values: _heightRange,
            min: 0,
            max: 100,
            divisions: 20,
            labels: RangeLabels(
              '${_heightRange.start.toInt()}m',
              '${_heightRange.end.toInt()}m',
            ),
            onChanged: (values) {
              setState(() {
                _heightRange = values;
              });
            },
          ),
          const SizedBox(height: 16),

          // Filtre par poids
          const Text(
            'Poids (kg)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          RangeSlider(
            values: _weightRange,
            min: 0,
            max: 1000,
            divisions: 20,
            labels: RangeLabels(
              '${_weightRange.start.toInt()}kg',
              '${_weightRange.end.toInt()}kg',
            ),
            onChanged: (values) {
              setState(() {
                _weightRange = values;
              });
            },
          ),
          const SizedBox(height: 16),

          // Filtre par stats
          const Text(
            'Stats totales',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          RangeSlider(
            values: RangeValues(_minStats.toDouble(), _maxStats.toDouble()),
            min: 0,
            max: 800,
            divisions: 20,
            labels: RangeLabels(_minStats.toString(), _maxStats.toString()),
            onChanged: (values) {
              setState(() {
                _minStats = values.start.toInt();
                _maxStats = values.end.toInt();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : _searchPokemon,
          icon: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.search),
          label: Text(_isLoading ? 'Recherche...' : 'Rechercher'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const LoadingWidget();
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 100, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Utilisez les filtres ci-dessus\npour rechercher des Pokémon',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 100, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Aucun résultat trouvé',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez avec des filtres différents',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16),
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
          child: Row(
            children: [
              Icon(Icons.filter_list, color: Colors.red.shade600, size: 24),
              const SizedBox(width: 12),
              Text(
                '${_searchResults.length} résultat(s) trouvé(s)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final pokemon = _searchResults[index];
              return _buildPokemonListItem(pokemon);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPokemonListItem(Pokemon pokemon) {
    final totalStats = pokemon.stats.fold(
      0,
      (sum, stat) => sum + stat.baseStat,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PokemonDetailPage(pokemon: pokemon),
            ),
          );
        },
        leading: Hero(
          tag: 'pokemon-${pokemon.id}',
          child: CachedNetworkImage(
            imageUrl: pokemon.imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.contain,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(
              Icons.catching_pokemon,
              size: 40,
              color: Colors.grey.shade400,
            ),
          ),
        ),
        title: Text(
          pokemon.name.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${pokemon.id}'),
            Text('Types: ${pokemon.types.join(', ')}'),
            Text('Taille: ${(pokemon.height / 10).toStringAsFixed(1)}m'),
            Text('Poids: ${(pokemon.weight / 10).toStringAsFixed(1)}kg'),
            Text('Stats totales: $totalStats'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
