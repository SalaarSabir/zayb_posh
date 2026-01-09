import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';
import '../core/utils/helpers.dart';

class CartProvider with ChangeNotifier {
  final List<CartItemModel> _items = [];
  List<CartItemModel> get items => _items;
  int get itemCount => _items.length;
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;
  int get totalQuantity {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }
  double get subtotal {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }
  double get shippingCost {
    return subtotal >= 5000 ? 0 : 200;
  }
  double get tax {
    return subtotal * 0.05;
  }
  double get total {
    return subtotal + shippingCost + tax;
  }
  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }
  CartItemModel? getCartItem(String productId) {
    try {
      return _items.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }
  void addToCart({
    required ProductModel product,
    required String selectedSize,
    required String selectedColor,
    int quantity = 1,
  }) {
    final existingIndex = _items.indexWhere(
          (item) =>
      item.product.id == product.id &&
          item.selectedSize == selectedSize &&
          item.selectedColor == selectedColor,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
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
  void removeFromCart(String cartItemId) {
    _items.removeWhere((item) => item.id == cartItemId);
    notifyListeners();
  }
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
  void increaseQuantity(String cartItemId) {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }
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
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
  double getDiscountAmount() {
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