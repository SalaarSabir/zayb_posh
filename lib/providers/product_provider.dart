// lib/providers/product_provider.dart
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class ProductProvider with ChangeNotifier {
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

  // Initialize with dummy data (temporary - real data from Firestore later)
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // Dummy Categories
      _categories = [
        CategoryModel(
          id: '1',
          name: 'T-Shirts',
          icon: '👕',
          image: 'https://via.placeholder.com/150',
          productCount: 25,
        ),
        CategoryModel(
          id: '2',
          name: 'Jeans',
          icon: '👖',
          image: 'https://via.placeholder.com/150',
          productCount: 18,
        ),
        CategoryModel(
          id: '3',
          name: 'Shoes',
          icon: '👟',
          image: 'https://via.placeholder.com/150',
          productCount: 30,
        ),
        CategoryModel(
          id: '4',
          name: 'Jackets',
          icon: '🧥',
          image: 'https://via.placeholder.com/150',
          productCount: 15,
        ),
        CategoryModel(
          id: '5',
          name: 'Accessories',
          icon: '🎒',
          image: 'https://via.placeholder.com/150',
          productCount: 40,
        ),
      ];

      // Dummy Products
      _products = [
        ProductModel(
          id: '1',
          name: 'Classic White T-Shirt',
          description: 'Premium cotton t-shirt with modern fit. Perfect for everyday wear.',
          price: 1500,
          originalPrice: 2000,
          category: 'T-Shirts',
          images: [
            'https://via.placeholder.com/400x500/FFFFFF/000000?text=White+T-Shirt',
          ],
          sizes: ['S', 'M', 'L', 'XL'],
          colors: ['White', 'Black', 'Navy'],
          stockQuantity: 50,
          isFeatured: true,
          isNewArrival: false,
          rating: 4.5,
          reviewCount: 120,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        ProductModel(
          id: '2',
          name: 'Slim Fit Jeans',
          description: 'Comfortable stretch denim jeans with slim fit design.',
          price: 3500,
          originalPrice: 4500,
          category: 'Jeans',
          images: [
            'https://via.placeholder.com/400x500/4169E1/FFFFFF?text=Blue+Jeans',
          ],
          sizes: ['28', '30', '32', '34', '36'],
          colors: ['Blue', 'Black', 'Grey'],
          stockQuantity: 35,
          isFeatured: true,
          isNewArrival: true,
          rating: 4.8,
          reviewCount: 95,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        ProductModel(
          id: '3',
          name: 'Sports Running Shoes',
          description: 'Lightweight running shoes with excellent cushioning and support.',
          price: 5500,
          category: 'Shoes',
          images: [
            'https://via.placeholder.com/400x500/32CD32/FFFFFF?text=Running+Shoes',
          ],
          sizes: ['7', '8', '9', '10', '11'],
          colors: ['White', 'Black', 'Red'],
          stockQuantity: 25,
          isFeatured: false,
          isNewArrival: true,
          rating: 4.6,
          reviewCount: 78,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        ProductModel(
          id: '4',
          name: 'Leather Jacket',
          description: 'Premium quality leather jacket with modern style.',
          price: 8500,
          originalPrice: 10000,
          category: 'Jackets',
          images: [
            'https://via.placeholder.com/400x500/8B4513/FFFFFF?text=Leather+Jacket',
          ],
          sizes: ['S', 'M', 'L', 'XL'],
          colors: ['Brown', 'Black'],
          stockQuantity: 15,
          isFeatured: true,
          isNewArrival: false,
          rating: 4.9,
          reviewCount: 156,
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
        ),
        ProductModel(
          id: '5',
          name: 'Cotton Polo Shirt',
          description: 'Comfortable polo shirt perfect for casual occasions.',
          price: 1800,
          category: 'T-Shirts',
          images: [
            'https://via.placeholder.com/400x500/FF6347/FFFFFF?text=Polo+Shirt',
          ],
          sizes: ['S', 'M', 'L', 'XL'],
          colors: ['Red', 'Blue', 'Green', 'White'],
          stockQuantity: 40,
          isFeatured: false,
          isNewArrival: true,
          rating: 4.3,
          reviewCount: 42,
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
        ProductModel(
          id: '6',
          name: 'Canvas Backpack',
          description: 'Durable canvas backpack with multiple compartments.',
          price: 2500,
          originalPrice: 3000,
          category: 'Accessories',
          images: [
            'https://via.placeholder.com/400x500/696969/FFFFFF?text=Backpack',
          ],
          sizes: ['One Size'],
          colors: ['Black', 'Grey', 'Navy'],
          stockQuantity: 30,
          isFeatured: false,
          isNewArrival: false,
          rating: 4.4,
          reviewCount: 67,
          createdAt: DateTime.now().subtract(const Duration(days: 45)),
        ),
      ];

      // Filter featured products
      _featuredProducts = _products.where((p) => p.isFeatured).toList();

      // Filter new arrivals
      _newArrivals = _products.where((p) => p.isNewArrival).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load products';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get products by category
  List<ProductModel> getProductsByCategory(String category) {
    return _products.where((p) => p.category == category).toList();
  }

  // Search products
  List<ProductModel> searchProducts(String query) {
    if (query.isEmpty) return _products;

    query = query.toLowerCase();
    return _products.where((product) {
      return product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query);
    }).toList();
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