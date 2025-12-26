// lib/providers/cart_provider.dart
import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';
import '../core/utils/helpers.dart';

class CartProvider with ChangeNotifier {
  final List<CartItemModel> _items = [];

  // Getters
  List<CartItemModel> get items => _items;
  int get itemCount => _items.length;
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  // Get total items quantity
  int get totalQuantity {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  // Get subtotal (sum of all items)
  double get subtotal {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Get shipping cost (free for orders above Rs. 5000)
  double get shippingCost {
    return subtotal >= 5000 ? 0 : 200;
  }

  // Get tax (5% of subtotal)
  double get tax {
    return subtotal * 0.05;
  }

  // Get total amount
  double get total {
    return subtotal + shippingCost + tax;
  }

  // Check if product is in cart
  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  // Get cart item by product ID
  CartItemModel? getCartItem(String productId) {
    try {
      return _items.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Add item to cart
  void addToCart({
    required ProductModel product,
    required String selectedSize,
    required String selectedColor,
    int quantity = 1,
  }) {
    // Check if same product with same size and color exists
    final existingIndex = _items.indexWhere(
          (item) =>
      item.product.id == product.id &&
          item.selectedSize == selectedSize &&
          item.selectedColor == selectedColor,
    );

    if (existingIndex >= 0) {
      // Update quantity if item already exists
      _items[existingIndex].quantity += quantity;
    } else {
      // Add new item
      final cartItem = CartItemModel(
        id: Helpers.generateId(),
        product: product,
        selectedSize: selectedSize,
        selectedColor: selectedColor,
        quantity: quantity,
      );
      _items.add(cartItem);
    }

    notifyListeners();
  }

  // Remove item from cart
  void removeFromCart(String cartItemId) {
    _items.removeWhere((item) => item.id == cartItemId);
    notifyListeners();
  }

  // Update item quantity
  void updateQuantity(String cartItemId, int quantity) {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      if (quantity > 0) {
        _items[index].quantity = quantity;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  // Increase quantity
  void increaseQuantity(String cartItemId) {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  // Decrease quantity
  void decreaseQuantity(String cartItemId) {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  // Clear cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Get discount amount (if any promotional discount)
  double getDiscountAmount() {
    // Calculate total discount from products
    double totalDiscount = 0;
    for (var item in _items) {
      if (item.product.hasDiscount) {
        final discount = (item.product.originalPrice! - item.product.price) * item.quantity;
        totalDiscount += discount;
      }
    }
    return totalDiscount;
  }
}