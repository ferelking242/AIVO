import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_review.dart';
import '../../providers/review_provider.dart';

class ProductReviewsWidget extends StatefulWidget {
  final String productId;

  const ProductReviewsWidget({
    required this.productId,
    super.key,
  });

  @override
  State<ProductReviewsWidget> createState() => _ProductReviewsWidgetState();
}

class _ProductReviewsWidgetState extends State<ProductReviewsWidget> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Load reviews when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewProvider>().fetchReviews(widget.productId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewProvider>(
      builder: (context, reviewProvider, _) {
        final reviews = reviewProvider.getReviewsForProduct(widget.productId);
        final stats = reviewProvider.getRatingStats(widget.productId);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating Summary
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${stats['average']?.toStringAsFixed(1) ?? '0.0'}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            final rating =
                                double.parse(stats['average'].toString());
                            return Icon(
                              index < rating.round()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            );
                          }),
                        ],
                      ),
                      Text(
                        '${stats['totalReviews']} reviews',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: [
                        ...[5, 4, 3, 2, 1].map((rating) {
                          final count =
                              stats['distribution']?[rating.toString()] ?? 0;
                          final total = stats['totalReviews'] ?? 1;
                          final percentage =
                              total > 0 ? (count / total * 100).toInt() : 0;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Text(
                                  '$rating',
                                  style:
                                      Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: LinearProgressIndicator(
                                      value: percentage / 100,
                                      minHeight: 4,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 30,
                                  child: Text(
                                    '$percentage%',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Individual Reviews
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Customer Reviews',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (reviewProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (reviews.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No reviews yet',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reviews.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return ProductReviewCard(
                    review: review,
                    productId: widget.productId,
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

class ProductReviewCard extends StatelessWidget {
  final ProductReview review;
  final String productId;

  const ProductReviewCard({
    required this.review,
    required this.productId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with rating and date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.userName,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < review.rating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        review.getFormattedDate(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              if (review.isVerifiedPurchase)
                Chip(
                  label: const Text('Verified Purchase'),
                  avatar: const Icon(Icons.verified),
                  labelStyle:
                      const TextStyle(color: Colors.white, fontSize: 10),
                  backgroundColor: Colors.green,
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Review Title
          Text(
            review.title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),

          // Review Comment
          Text(
            review.comment,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          // Photos (if any)
          if (review.photos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.photos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        review.photos[index],
                        width: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            width: 80,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),

          // Helpful Button
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    context
                        .read<ReviewProvider>()
                        .markHelpful(widget.productId, review.id);
                  },
                  icon: const Icon(Icons.thumb_up),
                  label: Text('Helpful (${review.helpfulCount})'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
