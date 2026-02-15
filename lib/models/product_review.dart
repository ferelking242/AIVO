import 'package:flutter/material.dart';

class ProductReview {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String title;
  final String comment;
  final DateTime createdAt;
  final int helpfulCount;
  List<String> photos;
  bool isVerifiedPurchase;

  ProductReview({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.title,
    required this.comment,
    required this.createdAt,
    this.helpfulCount = 0,
    this.photos = const [],
    this.isVerifiedPurchase = false,
  });

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'rating': rating,
      'title': title,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'helpful_count': helpfulCount,
      'photos': photos,
      'is_verified_purchase': isVerifiedPurchase,
    };
  }

  /// Create from JSON
  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userAvatar: json['user_avatar'] as String? ?? '',
      rating: (json['rating'] as num).toDouble(),
      title: json['title'] as String,
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      helpfulCount: json['helpful_count'] as int? ?? 0,
      photos: List<String>.from(json['photos'] as List? ?? []),
      isVerifiedPurchase: json['is_verified_purchase'] as bool? ?? false,
    );
  }

  /// Calculate average rating from list
  static double getAverageRating(List<ProductReview> reviews) {
    if (reviews.isEmpty) return 0.0;
    final sum = reviews.fold<double>(0, (sum, review) => sum + review.rating);
    return sum / reviews.length;
  }

  /// Group reviews by rating
  static Map<int, int> getRatingDistribution(List<ProductReview> reviews) {
    final distribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var review in reviews) {
      distribution[review.rating.toInt()] = (distribution[review.rating.toInt()] ?? 0) + 1;
    }
    return distribution;
  }

  /// Get formatted date
  String getFormattedDate() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else {
      return '${(difference.inDays / 365).floor()} years ago';
    }
  }
}
