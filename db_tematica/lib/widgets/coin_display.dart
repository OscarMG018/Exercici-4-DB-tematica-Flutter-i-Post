import 'package:flutter/material.dart';
import '../utils/coin_utils.dart';

class CoinDisplay extends StatelessWidget {
  final int value;
  final double iconSize;
  final bool compact;

  const CoinDisplay({
    super.key,
    required this.value,
    this.iconSize = 16,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (value == 0) {
      return const SizedBox.shrink(); // Return empty widget if value is 0
    }

    final coins = CoinUtils.calculateCoins(value);
    final List<Widget> coinWidgets = [];

    // Add platinum coins
    if (coins.containsKey('platinum')) {
      coinWidgets.addAll([
        Text(coins['platinum'].toString()),
        Image.asset(
          'assets/images/platinum_coin.png',
          width: iconSize,
          height: iconSize,
        ),
        if (!compact) const SizedBox(width: 4),
      ]);
    }

    // Add gold coins
    if (coins.containsKey('gold')) {
      coinWidgets.addAll([
        Text(coins['gold'].toString()),
        Image.asset(
          'assets/images/gold_coin.png',
          width: iconSize,
          height: iconSize,
        ),
        if (!compact) const SizedBox(width: 4),
      ]);
    }

    // Add silver coins
    if (coins.containsKey('silver')) {
      coinWidgets.addAll([
        Text(coins['silver'].toString()),
        Image.asset(
          'assets/images/silver_coin.png',
          width: iconSize,
          height: iconSize,
        ),
        if (!compact) const SizedBox(width: 4),
      ]);
    }

    // Add copper coins
    if (coins.containsKey('copper')) {
      coinWidgets.addAll([
        Text(coins['copper'].toString()),
        Image.asset(
          'assets/images/copper_coin.png',
          width: iconSize,
          height: iconSize,
        ),
      ]);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: coinWidgets,
    );
  }
} 