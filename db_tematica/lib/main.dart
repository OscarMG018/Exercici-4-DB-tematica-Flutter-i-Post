import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/categories_page.dart';
import 'providers/item_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ItemProvider(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Armes Terraria',
        home: CategoriesPage(),
      ),
    );
  }
}
