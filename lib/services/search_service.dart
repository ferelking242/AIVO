import 'dart:async';
import 'package:rxdart/rxdart.dart';
import '../models/Product.dart';
import '../services/product_service.dart';

class SearchService {
  static final SearchService _instance = SearchService._internal();

  factory SearchService() {
    return _instance;
  }

  SearchService._internal();

  final ProductService _productService = ProductService();
  final _searchSubject = BehaviorSubject<String>();
  final _resultsSubject = BehaviorSubject<List<Product>>();
  StreamSubscription? _searchSubscription;

  Stream<List<Product>> get results => _resultsSubject.stream;

  /// Initialize search with debounce (300ms)
  void initSearch() {
    _searchSubscription = _searchSubject
        .debounceTime(const Duration(milliseconds: 300))
        .switchMap((query) => _performSearch(query))
        .listen((results) {
          _resultsSubject.add(results);
        });
  }

  /// Stream search - returns results as stream
  Stream<List<Product>> _performSearch(String query) async* {
    if (query.isEmpty) {
      yield [];
      return;
    }

    try {
      final allProducts = await _productService.fetchAllProducts();
      final filtered = allProducts
          .where((product) =>
              product.title.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase()))
          .toList();

      yield filtered;
    } catch (e) {
      print('Error searching products: $e');
      yield [];
    }
  }

  /// Update search query
  void search(String query) {
    _searchSubject.add(query);
  }

  /// Get current results
  List<Product> get currentResults => _resultsSubject.value;

  /// Clear search
  void clear() {
    _searchSubject.add('');
  }

  /// Dispose streams
  void dispose() {
    _searchSubscription?.cancel();
    _searchSubject.close();
    _resultsSubject.close();
  }
}
