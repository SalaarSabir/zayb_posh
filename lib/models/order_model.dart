// lib/models/order_model.dart
import 'cart_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<CartItemModel> items;
  final double subtotal;
  final double shippingCost;
  final double tax;
  final double total;
  final String paymentMethod;
  final OrderStatus status;
  final String deliveryAddress;
  final String deliveryPhone;
  final String deliveryName;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final String? trackingNumber;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.shippingCost,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    required this.status,
    required this.deliveryAddress,
    required this.deliveryPhone,
    required this.deliveryName,
    required this.createdAt,
    this.deliveredAt,
    this.trackingNumber,
  });

  // Get total items count
  int get itemCount => items.length;

  // Get total quantity
  int get totalQuantity {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  // Get status color
  String get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return 'warning';
      case OrderStatus.confirmed:
        return 'info';
      case OrderStatus.processing:
        return 'primary';
      case OrderStatus.shipped:
        return 'secondary';
      case OrderStatus.delivered:
        return 'success';
      case OrderStatus.cancelled:
        return 'error';
    }
  }

  // Get status text
  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  // Can cancel order
  bool get canCancel {
    return status == OrderStatus.pending || status == OrderStatus.confirmed;
  }

  // Convert OrderModel to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'shippingCost': shippingCost,
      'tax': tax,
      'total': total,
      'paymentMethod': paymentMethod,
      'status': status.toString(),
      'deliveryAddress': deliveryAddress,
      'deliveryPhone': deliveryPhone,
      'deliveryName': deliveryName,
      'createdAt': createdAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'trackingNumber': trackingNumber,
    };
  }

  // Create OrderModel from Map
  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      items: (map['items'] as List<dynamic>)
          .map((item) => CartItemModel.fromMap(item))
          .toList(),
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      shippingCost: (map['shippingCost'] ?? 0).toDouble(),
      tax: (map['tax'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? '',
      status: OrderStatus.values.firstWhere(
            (e) => e.toString() == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      deliveryAddress: map['deliveryAddress'] ?? '',
      deliveryPhone: map['deliveryPhone'] ?? '',
      deliveryName: map['deliveryName'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      deliveredAt: map['deliveredAt'] != null
          ? DateTime.parse(map['deliveredAt'])
          : null,
      trackingNumber: map['trackingNumber'],
    );
  }

  @override
  String toString() {
    return 'OrderModel(id: $id, status: $statusText, total: $total)';
  }
}

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
}