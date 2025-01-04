import 'package:flutter/material.dart';
import '../models/item.dart';
import 'coin_display.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;

  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  Widget _buildObtainingSection() {
    if (item.obtainedBy.isNotEmpty) {
      return Text('Obtained by: ${item.obtainedBy}');
    } else if (item.createdWith.isNotEmpty) {
      return Text('Created with: ${item.createdWith}');
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: item.getImage(width: 50, height: 50),
        title: Text(item.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text('Damage: ${item.damage}'),
            _buildObtainingSection(),
          ],  
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (item.buyPrice > 0)
              CoinDisplay(
                value: item.buyPrice,
                compact: true,
                iconSize: 14,
              ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
        onTap: onTap,
        isThreeLine: true,
      ),
    );
  }
} 