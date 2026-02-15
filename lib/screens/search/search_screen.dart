import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/product_card.dart';
import '../../components/skeleton_loaders.dart';
import '../../models/Product.dart';
import '../../providers/search_provider.dart';
import '../details/details_screen.dart';

class SearchScreen extends StatefulWidget {
  static const String routeName = "/search";

  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;
  RangeValues _selectedPriceRange = const RangeValues(0, 1000);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Products'),
        elevation: 0,
      ),
      body: Consumer<SearchProvider>(
        builder: (context, searchProvider, _) {
          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    searchProvider.search(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              searchProvider.search('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),

              // Filter Toggle Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${searchProvider.totalResults} results',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showFilters = !_showFilters;
                        });
                      },
                      icon: const Icon(Icons.tune),
                      label: const Text('Filter'),
                    ),
                  ],
                ),
              ),

              // Filters Section (Expandable)
              if (_showFilters)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price Range Filter
                      Text(
                        'Price Range: \$${_selectedPriceRange.start.toInt()} - \$${_selectedPriceRange.end.toInt()}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      RangeSlider(
                        values: _selectedPriceRange,
                        min: 0,
                        max: 1000,
                        divisions: 100,
                        onChanged: (RangeValues values) {
                          setState(() {
                            _selectedPriceRange = values;
                          });
                          searchProvider.setPriceFilter(
                            values.start,
                            values.end,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                    ],
                  ),
                ),

              // Results Grid
              Expanded(
                child: searchProvider.isLoading
                    ? const SkeletonProductCardList(count: 6)
                    : searchProvider.searchResults.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No products found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 200,
                              childAspectRatio: 0.7,
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 16,
                            ),
                            itemCount: searchProvider.searchResults.length,
                            itemBuilder: (context, index) {
                              final product =
                                  searchProvider.searchResults[index];
                              return ProductCard(
                                product: product,
                                onPress: () => Navigator.pushNamed(
                                  context,
                                  DetailsScreen.routeName,
                                  arguments:
                                      ProductDetailsArguments(product: product),
                                ),
                              );
                            },
                          ),
              ),

              // Pagination Controls
              if (searchProvider.searchResults.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: searchProvider.hasPreviousPage
                            ? () => searchProvider.previousPage()
                            : null,
                        child: const Text('Previous'),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Page ${searchProvider.currentPage + 1}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: searchProvider.hasNextPage
                            ? () => searchProvider.nextPage()
                            : null,
                        child: const Text('Next'),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
