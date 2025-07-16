import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../services/api_service.dart';
import '../utils/pokemon_colors.dart';

class PokemonDetailPage extends StatefulWidget {
  final Pokemon pokemon;

  const PokemonDetailPage({super.key, required this.pokemon});

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage> {
  bool _isLiking = false;
  bool _isLiked = false;
  bool _isLoadingLikeState = true;

  @override
  void initState() {
    super.initState();
    _checkLikeState();
  }

  Future<void> _checkLikeState() async {
    try {
      final result = await ApiService.getLikes();
      if (result.success && result.data != null) {
        final isLiked = result.data!.any(
          (like) => like.pokemonId == widget.pokemon.id,
        );
        if (mounted) {
          setState(() {
            _isLiked = isLiked;
            _isLoadingLikeState = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingLikeState = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLikeState = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.pokemon.types.isNotEmpty
        ? PokemonTypeColors.getTypeColor(widget.pokemon.types.first)
        : Colors.grey;

    return Scaffold(
      backgroundColor: primaryColor.withOpacity(0.1),
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Text(_capitalize(widget.pokemon.name)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderSection(context, primaryColor),
            _buildInfoSection(context),
            _buildStatsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, Color primaryColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor,
            primaryColor.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Hero(
            tag: 'pokemon-${widget.pokemon.id}',
            child: CachedNetworkImage(
              imageUrl: widget.pokemon.imageUrl,
              height: 200,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(
                Icons.catching_pokemon,
                size: 200,
                color: Colors.grey.shade400,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '#${widget.pokemon.id.toString().padLeft(3, '0')}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _capitalize(widget.pokemon.name),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              _buildLikeButton(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.pokemon.types
                .map((type) => _buildTypeChip(type))
                .toList(),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: PokemonTypeColors.getTypeColor(type),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _capitalize(type),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
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
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Physical Attributes',
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
                child: _buildInfoItem(
                  'Height',
                  '${(widget.pokemon.height / 10).toStringAsFixed(1)} m',
                  Icons.height,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Weight',
                  '${(widget.pokemon.weight / 10).toStringAsFixed(1)} kg',
                  Icons.fitness_center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Abilities',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.pokemon.abilities
                .map(
                  (ability) => Chip(
                    label: Text(_capitalize(ability.replaceAll('-', ' '))),
                    backgroundColor: Colors.grey.shade100,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: Colors.grey.shade600),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
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
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Base Stats',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.pokemon.stats.map((stat) => _buildStatBar(stat)),
        ],
      ),
    );
  }

  Widget _buildStatBar(PokemonStat stat) {
    final maxStat = 200; // Maximum stat value for visualization
    final percentage = (stat.baseStat / maxStat).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              _formatStatName(stat.name),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 40,
            child: Text(
              stat.baseStat.toString(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: _getStatColor(stat.baseStat),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatStatName(String statName) {
    switch (statName) {
      case 'hp':
        return 'HP';
      case 'attack':
        return 'Attack';
      case 'defense':
        return 'Defense';
      case 'special-attack':
        return 'Sp. Atk';
      case 'special-defense':
        return 'Sp. Def';
      case 'speed':
        return 'Speed';
      default:
        return _capitalize(statName);
    }
  }

  Color _getStatColor(int statValue) {
    if (statValue >= 100) return Colors.green;
    if (statValue >= 80) return Colors.lightGreen;
    if (statValue >= 60) return Colors.orange;
    if (statValue >= 40) return Colors.yellow;
    return Colors.red;
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

  Widget _buildLikeButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: IconButton(
        onPressed: (_isLiking || _isLoadingLikeState) ? null : _toggleLike,
        icon: _isLoadingLikeState
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : _isLiking
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(
                _isLiked ? Icons.favorite : Icons.favorite_border,
                color: _isLiked ? Colors.red : Colors.white,
                size: 28,
              ),
      ),
    );
  }

  Future<void> _toggleLike() async {
    setState(() {
      _isLiking = true;
    });

    try {
      if (_isLiked) {
        // Unlike the pokemon
        final result = await ApiService.unlikePokemon(widget.pokemon.id);

        if (result.success) {
          if (mounted) {
            setState(() {
              _isLiked = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${_capitalize(widget.pokemon.name)} retiré des favoris!',
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  result.message ?? 'Erreur lors de la suppression des favoris',
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } else {
        // Like the pokemon
        final result = await ApiService.likePokemon(widget.pokemon.id);

        if (result.success) {
          if (mounted) {
            setState(() {
              _isLiked = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${_capitalize(widget.pokemon.name)} ajouté aux favoris!',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  result.message ?? 'Erreur lors de l\'ajout aux favoris',
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur de connexion'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLiking = false;
        });
      }
    }
  }
}
