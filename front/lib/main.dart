import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/splash_screen.dart';
import 'providers/pokemon_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => PokemonProvider())],
      child: MaterialApp(
        title: 'Poketter',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.red,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
