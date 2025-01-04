import 'package:flutter/material.dart';
import '../models/item.dart';
import '../widgets/coin_display.dart';

class ItemDetailPage extends StatelessWidget {
  final Item item;

  const ItemDetailPage({
    super.key,
    required this.item,
  });

  Widget _buildDetailRow(String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(child: value),
        ],
      ),
    );
  }

  Widget _buildTextDetailRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return _buildDetailRow(
      label,
      Text(
        value,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildPriceRow(String label, int value) {
    if (value == 0) return const SizedBox.shrink();
    return _buildDetailRow(
      label,
      CoinDisplay(value: value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: item.getImage(height: 200)),
              const SizedBox(height: 24),
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              _buildTextDetailRow('Category', item.category),
              _buildTextDetailRow('Damage', item.damage.toString()),
              _buildTextDetailRow('Auto Attack', item.autoAttack ? 'Yes' : 'No'),
              _buildTextDetailRow('Knockback', item.knockback.toString()),
              _buildTextDetailRow('Critical Chance', '${item.critChance}%'),
              _buildTextDetailRow('Use Time', '${item.useTime} frames'),
              _buildPriceRow('Buy Price', item.buyPrice),
              _buildPriceRow('Sell Price', item.sellPrice),
              _buildTextDetailRow('Created With', item.createdWith),
              _buildTextDetailRow('Obtained By', item.obtainedBy),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
} 