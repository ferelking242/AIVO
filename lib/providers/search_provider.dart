import 'package:flutter/material.dart';
import '../models/Product.dart';
import '../services/product_service.dart';
import '../services/search_service.dart';

class SearchProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();
  final SearchService _searchService = SearchService();

  List<Product> _allProducts = [];
  List<Product> _searchResults = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  int _totalItems = 0;

  // Filters
  double? _minPrice;
  double? _maxPrice;
  List<String> _selectedCategories = [];

  // Getters
  List<Product> get searchResults => _searchResults;
  List<Product> get filteredProducts => _filteredProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  int get currentPage => _currentPage;
  int get totalPages => (_totalItems / _itemsPerPage).ceil();
  bool get hasNextPage => _currentPage < totalPages;
  bool get hasPreviousPage => _currentPage > 1;

  SearchProvider() {
    _searchService.initSearch();
  }

  /// Perform search with query
  Future<void> search(String query) async {
    _searchQuery = query;
    _currentPage = 1;
    _searchService.search(query);

    if (query.isEmpty) {
      _searchResults = [];
    } else {
      _isLoading = true;
      notifyListeners();

      try {
        _allProducts = await _productService.fetchAllProducts();
        _applyFilters();
        _error = null;
      } catch (e) {
        _error = e.toString();
        _searchResults = [];
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Apply filters (price, category, search)
  void _applyFilters() {
    _filteredProducts = _allProducts.where((product) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final matchesQuery = product.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            product.description.toLowerCase().contains(_searchQuery.toLowerCase());
        if (!matchesQuery) return false;
      }

      // Price filter
      if (_minPrice != null && product.price < _minPrice!) return false;
      if (_maxPrice != null && product.price > _maxPrice!) return false;

      return true;
    }).toList();

    _totalItems = _filteredProducts.length;
    _updatePaginatedResults();
  }

  /// Update paginated results based on current page
  void _updatePaginatedResults() {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, _totalItems);

    _searchResults = startIndex < _totalItems
        ? _filteredProducts.sublist(startIndex, endIndex)
        : [];

    notifyListeners();
  }

  /// Set price filter
  void setPriceFilter(double? min, double? max) {
    _minPrice = min;
    _maxPrice = max;
    _currentPage = 1;
    _applyFilters();
  }

  /// Set category filter
  void setCategories(List<String> categories) {
    _selectedCategories = categories;
    _currentPage = 1;
    _applyFilters();
  }

  /// Go to next page
  void nextPage() {
    if (hasNextPage) {
      _currentPage++;
      _updatePaginatedResults();
    }
  }

  /// Go to previous page
  void previousPage() {
    if (hasPreviousPage) {
      _currentPage--;
      _updatePaginatedResults();
    }
  }

  /// Go to specific page
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      _currentPage = page;
      _updatePaginatedResults();
    }
  }

  /// Clear search and filters
  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _filteredProducts = [];
    _currentPage = 1;
    _minPrice = null;
    _maxPrice = null;
    _selectedCategories = [];
    _searchService.clear();
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _searchService.dispose();
    super.dispose();
  }
}
