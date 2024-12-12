import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final int itemCount;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.itemCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text('$itemCount items'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
} 