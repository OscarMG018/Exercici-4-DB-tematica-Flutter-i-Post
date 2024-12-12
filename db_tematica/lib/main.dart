import 'package:flutter/material.dart';
import 'screens/categories_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DB Tematica',
      home: CategoriesPage(),
    );
  }
}
