import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/cart_model.dart';
import '../core/services/order_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  bool get hasOrders => _orders.isNotEmpty;
  String? get errorMessage => _errorMessage;

  void initializeOrders(String userId) {
    _isLoading = true;
    notifyListeners();

    _orderService.getUserOrdersStream(userId).listen(
          (orders) {
        _orders = orders;
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
    try {
      _isLoading = true;
      notifyListeners();

      final order = OrderModel(
        id: '',
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
      );

      final orderId = await _orderService.placeOrder(order);

      final placedOrder = OrderModel(
        id: orderId,
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

      _isLoading = false;
      notifyListeners();

      return placedOrder;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  Future<bool> cancelOrder(String orderId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _orderService.cancelOrder(orderId);

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
  List<OrderModel> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }
  OrderModel? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}