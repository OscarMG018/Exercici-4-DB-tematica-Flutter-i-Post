import 'package:flutter/foundation.dart';
import '../models/item.dart';
import '../utils/data_utils.dart';

class ItemProvider with ChangeNotifier {
  List<String>? _categories;
  Map<String, int> _categoryItemCounts = {};
  List<Item>? _searchResults;
  String _searchQuery = '';

  List<String>? get categories => _categories;
  Map<String, int> get categoryItemCounts => _categoryItemCounts;
  List<Item>? get searchResults => _searchResults;
  String get searchQuery => _searchQuery;

  Future<void> loadCategories() async {
    _categories = await DataUtils.getCategories();
    await loadCategoryItemCounts();
    notifyListeners();
  }

  Future<void> loadCategoryItemCounts() async {
    if (_categories == null) return;
    
    for (final category in _categories!) {
      final items = await DataUtils.getItemsByCategory(category);
      _categoryItemCounts[category] = items.length;
    }
    notifyListeners();
  }

  Future<void> performSearch(String query) async {
    _searchQuery = query;
    if (query.isEmpty) {
      _searchResults = null;
      notifyListeners();
      return;
    }

    _searchResults = await DataUtils.getItemsBySearch(query);
    notifyListeners();
  }
} 