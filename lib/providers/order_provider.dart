// lib/providers/order_provider.dart
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/cart_model.dart';
import '../core/utils/helpers.dart';

class OrderProvider with ChangeNotifier {
  final List<OrderModel> _orders = [];
  bool _isLoading = false;

  // Getters
  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  bool get hasOrders => _orders.isNotEmpty;

  // Get orders by status
  List<OrderModel> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // Get order by ID
  OrderModel? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  // Place order
  Future<OrderModel> placeOrder({
    required String userId,
    required List<CartItemModel> items,
    required double subtotal,
    required double shippingCost,
    required double tax,
    required double total,
    required String paymentMethod,
    required String deliveryName,
    required String deliveryPhone,
    required String deliveryAddress,
  }) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    final order = OrderModel(
      id: Helpers.generateId(),
      userId: userId,
      items: items,
      subtotal: subtotal,
      shippingCost: shippingCost,
      tax: tax,
      total: total,
      paymentMethod: paymentMethod,
      status: OrderStatus.pending,
      deliveryAddress: deliveryAddress,
      deliveryPhone: deliveryPhone,
      deliveryName: deliveryName,
      createdAt: DateTime.now(),
      trackingNumber: 'TRK${DateTime.now().millisecondsSinceEpoch}',
    );

    _orders.insert(0, order); // Add at beginning (latest first)
    _isLoading = false;
    notifyListeners();

    return order;
  }

  // Cancel order
  Future<bool> cancelOrder(String orderId) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index >= 0 && _orders[index].canCancel) {
      // Create new order with cancelled status
      final cancelledOrder = OrderModel(
        id: _orders[index].id,
        userId: _orders[index].userId,
        items: _orders[index].items,
        subtotal: _orders[index].subtotal,
        shippingCost: _orders[index].shippingCost,
        tax: _orders[index].tax,
        total: _orders[index].total,
        paymentMethod: _orders[index].paymentMethod,
        status: OrderStatus.cancelled,
        deliveryAddress: _orders[index].deliveryAddress,
        deliveryPhone: _orders[index].deliveryPhone,
        deliveryName: _orders[index].deliveryName,
        createdAt: _orders[index].createdAt,
        trackingNumber: _orders[index].trackingNumber,
      );

      _orders[index] = cancelledOrder;
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Load dummy orders (for testing)
  void loadDummyOrders(String userId) {
    // Create some dummy orders
    final now = DateTime.now();

    _orders.clear();

    // Add dummy orders with different statuses
    _orders.addAll([
      // Recent delivered order
      OrderModel(
        id: Helpers.generateId(),
        userId: userId,
        items: [],
        subtotal: 5000,
        shippingCost: 0,
        tax: 250,
        total: 5250,
        paymentMethod: 'Cash on Delivery',
        status: OrderStatus.delivered,
        deliveryAddress: 'House 123, Street 45, Sector F-7, Islamabad',
        deliveryPhone: '+92 300 1234567',
        deliveryName: 'John Doe',
        createdAt: now.subtract(const Duration(days: 7)),
        deliveredAt: now.subtract(const Duration(days: 2)),
        trackingNumber: 'TRK${now.subtract(const Duration(days: 7)).millisecondsSinceEpoch}',
      ),

      // Shipped order
      OrderModel(
        id: Helpers.generateId(),
        userId: userId,
        items: [],
        subtotal: 3500,
        shippingCost: 200,
        tax: 175,
        total: 3875,
        paymentMethod: 'Credit Card',
        status: OrderStatus.shipped,
        deliveryAddress: 'House 123, Street 45, Sector F-7, Islamabad',
        deliveryPhone: '+92 300 1234567',
        deliveryName: 'John Doe',
        createdAt: now.subtract(const Duration(days: 3)),
        trackingNumber: 'TRK${now.subtract(const Duration(days: 3)).millisecondsSinceEpoch}',
      ),

      // Processing order
      OrderModel(
        id: Helpers.generateId(),
        userId: userId,
        items: [],
        subtotal: 2800,
        shippingCost: 200,
        tax: 140,
        total: 3140,
        paymentMethod: 'Cash on Delivery',
        status: OrderStatus.processing,
        deliveryAddress: 'House 123, Street 45, Sector F-7, Islamabad',
        deliveryPhone: '+92 300 1234567',
        deliveryName: 'John Doe',
        createdAt: now.subtract(const Duration(days: 1)),
        trackingNumber: 'TRK${now.subtract(const Duration(days: 1)).millisecondsSinceEpoch}',
      ),
    ]);

    notifyListeners();
  }
}