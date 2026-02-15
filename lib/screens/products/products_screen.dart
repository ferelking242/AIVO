import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aivo/components/product_card.dart';
import 'package:aivo/models/Product.dart';
import 'package:aivo/providers/product_provider.dart';
import 'package:aivo/components/skeleton_loaders.dart';
import 'package:aivo/utils/app_toast.dart';

import '../details/details_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  static String routeName = "/products";

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchAllProducts();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<ProductProvider>().fetchAllProducts();
    if (mounted) {
      AppToast.success(context, 'Products refreshed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading && productProvider.allProducts.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const SkeletonProductCardList(count: 8),
            );
          }

          if (productProvider.error != null && productProvider.allProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: ${productProvider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => productProvider.fetchAllProducts(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final products = productProvider.allProducts;

          if (products.isEmpty) {
            return const Center(child: Text('No products found'));
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 0.7,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) => ProductCard(
                    product: products[index],
                    onPress: () {
                      Navigator.pushNamed(
                        context,
                        DetailsScreen.routeName,
                        arguments: ProductDetailsArguments(product: products[index]),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
