import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../widgets/category_card.dart';
import '../widgets/item_card.dart';
import '../providers/item_provider.dart';
import 'item_detail_page.dart';
import 'item_list_page.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ItemProvider>().loadCategories());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: Consumer<ItemProvider>(
        builder: (context, itemProvider, child) {
          final showSearchResults = itemProvider.searchResults != null;

          return Column(
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
                    itemProvider.performSearch(value);
                  },
                ),
              ),
              Expanded(
                child: showSearchResults
                    ? ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: itemProvider.searchResults!.length,
                        itemBuilder: (context, index) {
                          final item = itemProvider.searchResults![index];
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
                    : itemProvider.categories == null
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: itemProvider.categories!.length,
                            itemBuilder: (context, index) {
                              final category = itemProvider.categories![index];
                              final itemCount = itemProvider.categoryItemCounts[category] ?? 0;

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
          );
        },
      ),
    );
  }
} 