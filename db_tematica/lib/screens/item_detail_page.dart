import 'package:flutter/material.dart';
import '../models/item.dart';

class ItemDetailPage extends StatelessWidget {
  final Item item;

  const ItemDetailPage({
    super.key,
    required this.item,
  });

  Widget _buildDetailRow(String label, String value) {
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
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
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
              Center(
                child: Image.asset(
                  item.image,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.image_not_supported, size: 200),
                ),
              ),
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
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Category', item.category),
              _buildDetailRow('Damage', item.damage.toString()),
              _buildDetailRow('Auto Attack', item.autoAttack ? 'Yes' : 'No'),
              _buildDetailRow('Knockback', item.knockback.toString()),
              _buildDetailRow('Critical Chance', '${item.critChance}%'),
              _buildDetailRow('Use Time', '${item.useTime} frames'),
              _buildDetailRow('Buy Price', '${item.buyPrice}g'),
              _buildDetailRow('Sell Price', '${item.sellPrice}g'),
              const SizedBox(height: 8),
              const Text(
                'Created With:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.createdWith,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Last Updated: ${item.updatedAt}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 