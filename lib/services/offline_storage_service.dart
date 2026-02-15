import 'package:hive_flutter/hive_flutter.dart';
import '../models/Product.dart';

class OfflineStorageService {
  static const String _productsBox = 'products_cache';
  static const String _cartBox = 'cart_cache';
  static const String _favoritesBox = 'favorites_cache';
  static const String _lastSyncBox = 'last_sync';

  static final OfflineStorageService _instance =
      OfflineStorageService._internal();

  factory OfflineStorageService() {
    return _instance;
  }

  OfflineStorageService._internal();

  /// Initialize Hive and open boxes
  Future<void> initialize() async {
    try {
      await Hive.initFlutter();

      // Register adapters if using Hive models
      // Hive.registerAdapter(ProductAdapter());

      // Open boxes
      await Hive.openBox(_productsBox);
      await Hive.openBox(_cartBox);
      await Hive.openBox(_favoritesBox);
      await Hive.openBox<String>(_lastSyncBox);

      print('Offline storage initialized successfully');
    } catch (e) {
      print('Error initializing offline storage: $e');
    }
  }

  // ==================== Products Cache ====================

  /// Cache products locally
  Future<void> cacheProducts(List<Product> products) async {
    try {
      final productsBox = Hive.box(_productsBox);
      final data = products.map((p) => p.toJson()).toList();
      await productsBox.putAll({
        'all_products': data,
        'sync_time': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error caching products: $e');
    }
  }

  /// Get cached products
  List<Product> getCachedProducts() {
    try {
      final productsBox = Hive.box(_productsBox);
      final data = productsBox.get('all_products');

      if (data != null && data is List) {
        return data
            .map((item) => Product.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error retrieving cached products: $e');
      return [];
    }
  }

  /// Cache popular products
  Future<void> cachePopularProducts(List<Product> products) async {
    try {
      final productsBox = Hive.box(_productsBox);
      final data = products.map((p) => p.toJson()).toList();
      await productsBox.put('popular_products', data);
    } catch (e) {
      print('Error caching popular products: $e');
    }
  }

  /// Get cached popular products
  List<Product> getCachedPopularProducts() {
    try {
      final productsBox = Hive.box(_productsBox);
      final data = productsBox.get('popular_products');

      if (data != null && data is List) {
        return data
            .map((item) => Product.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error retrieving cached popular products: $e');
      return [];
    }
  }

  // ==================== Cart Cache ====================

  /// Cache cart items
  Future<void> cacheCart(Map<String, dynamic> cartData) async {
    try {
      final cartBox = Hive.box(_cartBox);
      await cartBox.putAll(cartData);
    } catch (e) {
      print('Error caching cart: $e');
    }
  }

  /// Get cached cart
  Map<String, dynamic> getCachedCart() {
    try {
      final cartBox = Hive.box(_cartBox);
      final result = <String, dynamic>{};
      for (var key in cartBox.keys) {
        result[key.toString()] = cartBox.get(key);
      }
      return result;
    } catch (e) {
      print('Error retrieving cached cart: $e');
      return {};
    }
  }

  /// Clear cart cache
  Future<void> clearCartCache() async {
    try {
      final cartBox = Hive.box(_cartBox);
      await cartBox.clear();
    } catch (e) {
      print('Error clearing cart cache: $e');
    }
  }

  // ==================== Favorites Cache ====================

  /// Cache favorites
  Future<void> cacheFavorites(List<int> favoriteIds) async {
    try {
      final favoritesBox = Hive.box(_favoritesBox);
      await favoritesBox.put('favorite_ids', favoriteIds);
    } catch (e) {
      print('Error caching favorites: $e');
    }
  }

  /// Get cached favorites
  List<int> getCachedFavorites() {
    try {
      final favoritesBox = Hive.box(_favoritesBox);
      final data = favoritesBox.get('favorite_ids');
      if (data != null && data is List) {
        return List<int>.from(data);
      }
      return [];
    } catch (e) {
      print('Error retrieving cached favorites: $e');
      return [];
    }
  }

  // ==================== Sync Management ====================

  /// Get last sync time
  DateTime? getLastSyncTime() {
    try {
      final syncBox = Hive.box<String>(_lastSyncBox);
      final time = syncBox.get('last_sync');
      if (time != null) {
        return DateTime.parse(time);
      }
      return null;
    } catch (e) {
      print('Error getting last sync time: $e');
      return null;
    }
  }

  /// Update last sync time
  Future<void> updateLastSyncTime() async {
    try {
      final syncBox = Hive.box<String>(_lastSyncBox);
      await syncBox.put('last_sync', DateTime.now().toIso8601String());
    } catch (e) {
      print('Error updating sync time: $e');
    }
  }

  /// Check if sync is needed (older than 1 hour)
  bool isSyncNeeded() {
    final lastSync = getLastSyncTime();
    if (lastSync == null) {
      return true;
    }
    return DateTime.now().difference(lastSync).inMinutes > 60;
  }

  // ==================== General ====================

  /// Clear all cached data
  Future<void> clearAllCache() async {
    try {
      await Hive.box(_productsBox).clear();
      await Hive.box(_cartBox).clear();
      await Hive.box(_favoritesBox).clear();
      print('All cache cleared');
    } catch (e) {
      print('Error clearing all cache: $e');
    }
  }

  /// Get cache size
  int getCacheSize() {
    try {
      int size = 0;
      size += Hive.box(_productsBox).length;
      size += Hive.box(_cartBox).length;
      size += Hive.box(_favoritesBox).length;
      return size;
    } catch (e) {
      print('Error getting cache size: $e');
      return 0;
    }
  }
}
