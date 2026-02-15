import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aivo/components/product_card.dart';
import 'package:aivo/components/skeleton_loaders.dart';
import 'package:aivo/providers/product_provider.dart';

import '../details/details_screen.dart';

class FavoriteScreen extends StatefulWidget {
  static const String routeName = "/favorites";

  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  void initState() {
    super.initState();
    // Load user favorites when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchUserFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Text(
            "Favorites",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Consumer<ProductProvider>(
                builder: (context, productProvider, child) {
                  if (productProvider.isLoading) {
                    return const SkeletonProductCardList(count: 6);
                  }

                  final favorites = productProvider.userFavorites;

                  if (favorites.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.favorite_border,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No favorites yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              productProvider.fetchUserFavorites();
                            },
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    itemCount: favorites.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 0.7,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) => ProductCard(
                      product: favorites[index],
                      onPress: () => Navigator.pushNamed(
                        context,
                        DetailsScreen.routeName,
                        arguments: ProductDetailsArguments(
                            product: favorites[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
