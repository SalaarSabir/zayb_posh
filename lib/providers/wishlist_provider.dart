import 'package:flutter/material.dart';
import '../core/services/wishlist_service.dart';
import '../models/product_model.dart';

class WishlistProvider with ChangeNotifier {
  final WishlistService _wishlistService = WishlistService();

  List<String> _wishlistProductIds = [];
  bool _isLoading = false;

  List<String> get wishlistProductIds => _wishlistProductIds;
  bool get isLoading => _isLoading;
  int get wishlistCount => _wishlistProductIds.length;
  bool get isEmpty => _wishlistProductIds.isEmpty;
  void initializeWishlist(String userId) {
    _wishlistService.getUserWishlistStream(userId).listen(
          (productIds) {
        _wishlistProductIds = productIds;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }
  bool isInWishlist(String productId) {
    return _wishlistProductIds.contains(productId);
  }
  Future<bool> toggleWishlist(String userId, String productId) async {
    try {
      if (isInWishlist(productId)) {
        await _wishlistService.removeFromWishlist(userId, productId);
      } else {
        await _wishlistService.addToWishlist(userId, productId);
      }
      return true;
    } catch (e) {
      return false;
    }
  }
  Future<bool> addToWishlist(String userId, String productId) async {
    try {
      await _wishlistService.addToWishlist(userId, productId);
      return true;
    } catch (e) {
      return false;
    }
  }
  Future<bool> removeFromWishlist(String userId, String productId) async {
    try {
      await _wishlistService.removeFromWishlist(userId, productId);
      return true;
    } catch (e) {
      return false;
    }
  }
  Future<bool> clearWishlist(String userId) async {
    try {
      await _wishlistService.clearWishlist(userId);
      return true;
    } catch (e) {
      return false;
    }
  }
  List<ProductModel> getWishlistProducts(List<ProductModel> allProducts) {
    return allProducts
        .where((product) => _wishlistProductIds.contains(product.id))
        .toList();
  }
}