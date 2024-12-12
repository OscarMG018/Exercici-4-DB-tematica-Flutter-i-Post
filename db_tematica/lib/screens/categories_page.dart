import 'package:flutter/material.dart';
import '../models/item.dart';
import '../utils/data_utils.dart';
import '../widgets/category_card.dart';
import '../widgets/item_card.dart';
import 'item_detail_page.dart';
import 'item_list_page.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  String searchQuery = '';
  List<Item>? searchResults;
  List<String>? categories;
  Map<String, int> categoryItemCounts = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final loadedCategories = await DataUtils.getCategories();
    setState(() {
      categories = loadedCategories;
    });
    _loadCategoryItemCounts();
  }

  Future<void> _loadCategoryItemCounts() async {
    if (categories == null) return;
    
    for (final category in categories!) {
      final items = await DataUtils.getItemsByCategory(category);
      setState(() {
        categoryItemCounts[category] = items.length;
      });
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = null;
      });
      return;
    }

    final results = await DataUtils.getItemsBySearch(query);
    setState(() {
      searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final showSearchResults = searchResults != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search items...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
                _performSearch(value);
              },
            ),
          ),
          Expanded(
            child: showSearchResults
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: searchResults!.length,
                    itemBuilder: (context, index) {
                      final item = searchResults![index];
                      return ItemCard(
                        item: item,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ItemDetailPage(item: item),
                            ),
                          );
                        },
                      );
                    },
                  )
                : categories == null
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: categories!.length,
                        itemBuilder: (context, index) {
                          final category = categories![index];
                          final itemCount = categoryItemCounts[category] ?? 0;

                          return CategoryCard(
                            title: category,
                            itemCount: itemCount,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ItemListPage(category: category),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
} 