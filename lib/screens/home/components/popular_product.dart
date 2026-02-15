import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../components/product_card.dart';
import '../../../components/skeleton_loaders.dart';
import '../../../models/Product.dart';
import '../../../providers/product_provider.dart';
import '../../details/details_screen.dart';
import '../../products/products_screen.dart';
import 'section_title.dart';

class PopularProducts extends StatefulWidget {
  const PopularProducts({super.key});

  @override
  State<PopularProducts> createState() => _PopularProductsState();
}

class _PopularProductsState extends State<PopularProducts> {
  @override
  void initState() {
    super.initState();
    // Load popular products when component initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchPopularProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final popularProducts = productProvider.popularProducts;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SectionTitle(
                title: "Popular Products",
                press: () {
                  Navigator.pushNamed(context, ProductsScreen.routeName);
                },
              ),
            ),
            if (productProvider.isLoading)
              Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      ...List.generate(4, (_) => const Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: SkeletonCard(
                          height: 180,
                          width: 140,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      )),
                    ],
                  ),
                ),
              )
            else if (popularProducts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text('No popular products available'),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...popularProducts.map((product) => Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: ProductCard(
                        product: product,
                        onPress: () => Navigator.pushNamed(
                          context,
                          DetailsScreen.routeName,
                          arguments: ProductDetailsArguments(product: product),
                        ),
                      ),
                    )),
                    const SizedBox(width: 20),
                  ],
                ),
              )
          ],
        );
      },
    );
  }
}
