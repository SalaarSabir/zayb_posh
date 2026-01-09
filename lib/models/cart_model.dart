import 'product_model.dart';
class CartItemModel {
  final String id;
  final ProductModel product;
  final String selectedSize;
  final String selectedColor;
  int quantity;

  CartItemModel({
    required this.id,
    required this.product,
    required this.selectedSize,
    required this.selectedColor,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product': product.toMap(),
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
      'quantity': quantity,
    };
  }
  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'] ?? '',
      product: ProductModel.fromMap(map['product']),
      selectedSize: map['selectedSize'] ?? '',
      selectedColor: map['selectedColor'] ?? '',
      quantity: map['quantity'] ?? 1,
    );
  }
  CartItemModel copyWith({
    String? id,
    ProductModel? product,
    String? selectedSize,
    String? selectedColor,
    int? quantity,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  String toString() {
    return 'CartItemModel(id: $id, product: ${product.name}, quantity: $quantity)';
  }
}