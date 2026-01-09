import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _ordersCollection => _firestore.collection('orders');

  Future<String> placeOrder(OrderModel order) async {
    try {
      final docRef = _ordersCollection.doc();
      final orderId = docRef.id;

      final orderWithId = OrderModel(
        id: orderId,
        userId: order.userId,
        items: order.items,
        subtotal: order.subtotal,
        shippingCost: order.shippingCost,
        tax: order.tax,
        total: order.total,
        paymentMethod: order.paymentMethod,
        status: order.status,
        deliveryAddress: order.deliveryAddress,
        deliveryPhone: order.deliveryPhone,
        deliveryName: order.deliveryName,
        createdAt: DateTime.now(),
        trackingNumber: 'TRK${DateTime.now().millisecondsSinceEpoch}',
      );

      await docRef.set(orderWithId.toMap());
      return orderId;
    } catch (e) {
      throw 'Failed to place order: $e';
    }
  }
  Stream<List<OrderModel>> getUserOrdersStream(String userId) {
    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _ordersCollection.doc(orderId).update({
        'status': status.toString(),
      });
    } catch (e) {
      throw 'Failed to update order status: $e';
    }
  }
  Future<void> cancelOrder(String orderId) async {
    try {
      await _ordersCollection.doc(orderId).update({
        'status': OrderStatus.cancelled.toString(),
      });
    } catch (e) {
      throw 'Failed to cancel order: $e';
    }
  }
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _ordersCollection.doc(orderId).get();
      if (doc.exists) {
        return OrderModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw 'Failed to get order: $e';
    }
  }
  Stream<List<OrderModel>> getAllOrdersStream() {
    return _ordersCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}