import '../models/item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DataUtils {
  static const String baseUrl = 'http://localhost:3000/api';
  static final Map<String, List<Item>> _itemsByCategory = {};
  static final Map<String, List<Item>> _itemsBySearch = {};
  static List<String>? _categories;

  DataUtils();

  static Future<List<Item>> getItemsByCategory(String category) async {
    if (_itemsByCategory.containsKey(category)) {
      return _itemsByCategory[category]!;
    }
    
    final response = await http.get(Uri.parse('$baseUrl/items/category/$category'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> itemsJson = jsonResponse['data'];
      final items = itemsJson.map((json) => Item.fromJson(json)).toList();
      _itemsByCategory[category] = items;
      return items;
    }
    return [];
  }

  static Future<List<Item>> getItemsBySearch(String searchQuery) async {
    if (_itemsBySearch.containsKey(searchQuery)) {
      return _itemsBySearch[searchQuery]!;
    }
    
    final response = await http.get(Uri.parse('$baseUrl/items/search/$searchQuery'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> itemsJson = jsonResponse['data'];
      final items = itemsJson.map((json) => Item.fromJson(json)).toList();
      _itemsBySearch[searchQuery] = items;
      return items;
    }
    return [];
  }

  static Future<List<String>> getCategories() async {
    if (_categories != null) {
      return _categories!;
    }
    
    final response = await http.get(Uri.parse('$baseUrl/categories'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> categoriesJson = jsonResponse['data'];
      _categories = categoriesJson.cast<String>();
      return _categories!;
    }
    return [];
  }
} 