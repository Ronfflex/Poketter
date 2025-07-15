import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pokemon.dart';

class PokemonService {
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  Future<List<PokemonListItem>> getPokemonList({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pokemon?limit=$limit&offset=$offset'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        return results
            .map((pokemon) => PokemonListItem.fromJson(pokemon))
            .toList();
      } else {
        throw Exception('Failed to load Pokemon list');
      }
    } catch (e) {
      throw Exception('Failed to load Pokemon list: $e');
    }
  }

  Future<Pokemon> getPokemon(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/pokemon/$id'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Pokemon.fromJson(data);
      } else {
        throw Exception('Failed to load Pokemon details');
      }
    } catch (e) {
      throw Exception('Failed to load Pokemon details: $e');
    }
  }

  Future<Pokemon> getPokemonByName(String name) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pokemon/${name.toLowerCase()}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Pokemon.fromJson(data);
      } else {
        throw Exception('Failed to load Pokemon details');
      }
    } catch (e) {
      throw Exception('Failed to load Pokemon details: $e');
    }
  }

  Future<List<String>> getPokemonTypes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/type'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        return results.map((type) => type['name'] as String).toList();
      } else {
        throw Exception('Failed to load Pokemon types');
      }
    } catch (e) {
      throw Exception('Failed to load Pokemon types: $e');
    }
  }

  Future<List<PokemonListItem>> getPokemonByType(String type) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/type/$type'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final pokemon = data['pokemon'] as List;

        return pokemon
            .map((p) => PokemonListItem.fromJson(p['pokemon']))
            .toList();
      } else {
        throw Exception('Failed to load Pokemon by type');
      }
    } catch (e) {
      throw Exception('Failed to load Pokemon by type: $e');
    }
  }
}
