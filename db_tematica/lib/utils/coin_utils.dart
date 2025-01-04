class CoinUtils {
  static const int COPPER = 1;
  static const int SILVER = 100;
  static const int GOLD = 10000;
  static const int PLATINUM = 1000000;

  static Map<String, int> calculateCoins(int value) {
    final Map<String, int> coins = {};

    // Calculate platinum coins
    if (value >= PLATINUM) {
      coins['platinum'] = value ~/ PLATINUM;
      value = value % PLATINUM;
    }

    // Calculate gold coins
    if (value >= GOLD) {
      coins['gold'] = value ~/ GOLD;
      value = value % GOLD;
    }

    // Calculate silver coins
    if (value >= SILVER) {
      coins['silver'] = value ~/ SILVER;
      value = value % SILVER;
    }

    // Remaining copper coins
    if (value > 0) {
      coins['copper'] = value;
    }

    return coins;
  }
} 