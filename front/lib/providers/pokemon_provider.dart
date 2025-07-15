import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../services/pokemon_service.dart';

class PokemonProvider extends ChangeNotifier {
  final PokemonService _pokemonService = PokemonService();

  List<PokemonListItem> _pokemonList = [];
  List<PokemonListItem> _filteredPokemonList = [];
  List<String> _pokemonTypes = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isSearching = false;
  String _error = '';
  String _selectedType = '';
  String _searchQuery = '';
  int _currentOffset = 0;
  static const int _limit = 20;
  bool _isSearchMode = false;

  List<PokemonListItem> get pokemonList => _filteredPokemonList;
  List<String> get pokemonTypes => _pokemonTypes;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isSearching => _isSearching;
  String get error => _error;
  String get selectedType => _selectedType;
  String get searchQuery => _searchQuery;
  bool get isSearchMode => _isSearchMode;

  Future<void> loadPokemonList({bool loadMore = false}) async {
    if (loadMore) {
      _isLoadingMore = true;
    } else {
      _isLoading = true;
      _currentOffset = 0;
      _pokemonList.clear();
      _filteredPokemonList.clear();
    }
    _error = '';
    notifyListeners();

    try {
      List<PokemonListItem> newPokemon;

      if (_selectedType.isNotEmpty) {
        newPokemon = await _pokemonService.getPokemonByType(_selectedType);
        _pokemonList = newPokemon;
      } else {
        newPokemon = await _pokemonService.getPokemonList(
          limit: _limit,
          offset: _currentOffset,
        );
        if (loadMore) {
          _pokemonList.addAll(newPokemon);
        } else {
          _pokemonList = newPokemon;
        }
        _currentOffset += _limit;
      }

      _applyFilters();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadPokemonTypes() async {
    try {
      _pokemonTypes = await _pokemonService.getPokemonTypes();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void setTypeFilter(String type) {
    _selectedType = type;
    loadPokemonList();
  }

  void clearTypeFilter() {
    _selectedType = '';
    loadPokemonList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    if (query.trim().isEmpty) {
      _clearSearchMode();
    } else {
      _performSearch(query.trim());
    }
  }

  void _clearSearchMode() {
    _isSearchMode = false;
    _applyFilters();
    notifyListeners();
  }

  void _performSearch(String query) async {
    // Check if it's a Pokemon ID (numeric)
    final pokemonId = int.tryParse(query);
    if (pokemonId != null) {
      await _searchPokemonById(pokemonId);
      return;
    }

    // Check if it might be an exact Pokemon name
    await _searchPokemonByName(query);
  }

  Future<void> _searchPokemonById(int id) async {
    _isSearching = true;
    _isSearchMode = true;
    _error = '';
    notifyListeners();

    try {
      final pokemon = await _pokemonService.getPokemon(id);
      final pokemonListItem = PokemonListItem(
        name: pokemon.name,
        url: 'https://pokeapi.co/api/v2/pokemon/$id/',
        id: id,
      );
      _filteredPokemonList = [pokemonListItem];
    } catch (e) {
      _error = 'Pokemon with ID $id not found';
      _filteredPokemonList = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<void> _searchPokemonByName(String name) async {
    _isSearching = true;
    _isSearchMode = true;
    _error = '';
    notifyListeners();

    try {
      final pokemon = await _pokemonService.getPokemonByName(name);
      final pokemonListItem = PokemonListItem(
        name: pokemon.name,
        url: 'https://pokeapi.co/api/v2/pokemon/${pokemon.id}/',
        id: pokemon.id,
      );
      _filteredPokemonList = [pokemonListItem];
    } catch (e) {
      // If exact search fails, fall back to local filtering
      _isSearchMode = false;
      _applyFilters();
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void _applyFilters() {
    if (_isSearchMode) return; // Don't apply local filters in search mode

    _filteredPokemonList = _pokemonList.where((pokemon) {
      if (_searchQuery.isEmpty) return true;
      return pokemon.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<Pokemon> getPokemonDetails(int id) async {
    return await _pokemonService.getPokemon(id);
  }
}
