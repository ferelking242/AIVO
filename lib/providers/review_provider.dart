import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_review.dart';
import '../services/auth_service.dart';

class ReviewProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService = AuthService();

  Map<String, List<ProductReview>> _productReviews = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch reviews for a product
  Future<List<ProductReview>> fetchProductReviews(String productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('product_reviews')
          .select()
          .eq('product_id', productId)
          .order('created_at', ascending: false);

      final reviews = (response as List)
          .map((item) => ProductReview.fromJson(item))
          .toList();

      _productReviews[productId] = reviews;
      _error = null;
      return reviews;
    } catch (e) {
      _error = e.toString();
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get cached reviews for product
  List<ProductReview> getProductReviews(String productId) {
    return _productReviews[productId] ?? [];
  }

  /// Alias for getProductReviews
  List<ProductReview> getReviewsForProduct(String productId) {
    return getProductReviews(productId);
  }

  /// Alias for fetchProductReviews
  Future<void> fetchReviews(String productId) async {
    await fetchProductReviews(productId);
  }

  /// Add a review
  Future<bool> addReview({
    required String productId,
    required double rating,
    required String title,
    required String comment,
    List<String> photos = const [],
  }) async {
    try {
      final user = _authService.getCurrentUser();
      if (user == null) {
        _error = 'User not authenticated';
        return false;
      }

      final review = ProductReview(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: productId,
        userId: user.id,
        userName: user.email ?? 'Anonymous',
        userAvatar: '',
        rating: rating,
        title: title,
        comment: comment,
        createdAt: DateTime.now(),
        photos: photos,
        isVerifiedPurchase: true,
      );

      await _supabase.from('product_reviews').insert(review.toJson());

      // Update cached reviews
      if (_productReviews.containsKey(productId)) {
        _productReviews[productId]!.insert(0, review);
      } else {
        _productReviews[productId] = [review];
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete a review
  Future<bool> deleteReview(String reviewId, String productId) async {
    try {
      await _supabase.from('product_reviews').delete().eq('id', reviewId);

      // Update cached reviews
      if (_productReviews.containsKey(productId)) {
        _productReviews[productId]!.removeWhere((r) => r.id == reviewId);
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  /// Mark review as helpful
  Future<bool> markHelpful(String reviewId, String productId) async {
    try {
      final review = _productReviews[productId]
          ?.firstWhere((r) => r.id == reviewId, orElse: () => ProductReview(
            id: '',
            productId: '',
            userId: '',
            userName: '',
            userAvatar: '',
            rating: 0,
            title: '',
            comment: '',
            createdAt: DateTime.now(),
          ));

      if (review != null && review.id.isNotEmpty) {
        // Note: helpfulCount is final, so we would need to create a new object
        // For now, we'll just update the database
        await _supabase
            .from('product_reviews')
            .update({'helpful_count': (review.helpfulCount + 1)})
            .eq('id', reviewId);

        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  /// Get rating statistics for product
  Map<String, dynamic> getRatingStats(String productId) {
    final reviews = getProductReviews(productId);
    if (reviews.isEmpty) {
      return {
        'average': 0.0,
        'total': 0,
        'distribution': {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
      };
    }

    return {
      'average': ProductReview.getAverageRating(reviews),
      'total': reviews.length,
      'distribution': ProductReview.getRatingDistribution(reviews),
    };
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
