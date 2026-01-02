// lib/providers/product_provider.dart
import 'package:flutter/material.dart';
import 'dart:io';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../core/services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();

  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  List<ProductModel> _featuredProducts = [];
  List<ProductModel> _newArrivals = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<ProductModel> get products => _products;
  List<CategoryModel> get categories => _categories;
  List<ProductModel> get featuredProducts => _featuredProducts;
  List<ProductModel> get newArrivals => _newArrivals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize and listen to real-time updates
  void initializeProducts() {
    _isLoading = true;
    notifyListeners();

    // Listen to products stream
    _productService.getProductsStream().listen(
          (products) {
        _products = products;
        _featuredProducts = products.where((p) => p.isFeatured).toList();
        _newArrivals = products.where((p) => p.isNewArrival).toList();
        _updateCategories();
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Update categories based on products
  void _updateCategories() {
    final Map<String, int> categoryCount = {};

    for (final product in _products) {
      categoryCount[product.category] = (categoryCount[product.category] ?? 0) + 1;
    }

    _categories = categoryCount.entries.map((entry) {
      return CategoryModel(
        id: entry.key.toLowerCase().replaceAll(' ', '_'),
        name: entry.key,
        icon: _getCategoryIcon(entry.key),
        image: '',
        productCount: entry.value,
      );
    }).toList();
  }

  // Get category icon
  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 't-shirts':
        return '👕';
      case 'jeans':
        return '👖';
      case 'shoes':
        return '👟';
      case 'jackets':
        return '🧥';
      case 'accessories':
        return '🎒';
      case 'dresses':
        return '👗';
      case 'shirts':
        return '👔';
      case 'pants':
        return '👖';
      default:
        return '🛍️';
    }
  }

  // Load products (kept for compatibility)
  Future<void> loadProducts() async {
    initializeProducts();
  }

  // Add product (Admin)
  Future<bool> addProduct(ProductModel product, {File? imageFile}) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _productService.addProduct(product, imageFile: imageFile);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update product (Admin)
  Future<bool> updateProduct(ProductModel product, {File? newImageFile}) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _productService.updateProduct(product, newImageFile: newImageFile);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete product (Admin)
  Future<bool> deleteProduct(String productId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _productService.deleteProduct(productId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get products by category
  List<ProductModel> getProductsByCategory(String category) {
    return _products.where((p) => p.category == category).toList();
  }

  // Search products
  Future<List<ProductModel>> searchProducts(String query) async {
    if (query.isEmpty) return _products;

    try {
      return await _productService.searchProducts(query);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Get product by ID
  ProductModel? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}