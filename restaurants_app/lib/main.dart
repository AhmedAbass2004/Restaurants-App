import 'package:flutter/material.dart';

import 'screens/splash/splash_screen.dart';

void main() {
  runApp(const RestaurantsApp());
}

class RestaurantsApp extends StatelessWidget {
  const RestaurantsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurants App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      home: const SplashScreen(),
    );
  }
}
