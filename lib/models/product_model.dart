class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String category;
  final List<String> images;
  final List<String> sizes;
  final List<String> colors;
  final int stockQuantity;
  final bool isFeatured;
  final bool isNewArrival;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.category,
    required this.images,
    required this.sizes,
    required this.colors,
    required this.stockQuantity,
    this.isFeatured = false,
    this.isNewArrival = false,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
  });
  bool get isInStock => stockQuantity > 0;
  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  int get discountPercentage {
    if (!hasDiscount) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'category': category,
      'images': images,
      'sizes': sizes,
      'colors': colors,
      'stockQuantity': stockQuantity,
      'isFeatured': isFeatured,
      'isNewArrival': isNewArrival,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      originalPrice: map['originalPrice']?.toDouble(),
      category: map['category'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      sizes: List<String>.from(map['sizes'] ?? []),
      colors: List<String>.from(map['colors'] ?? []),
      stockQuantity: map['stockQuantity'] ?? 0,
      isFeatured: map['isFeatured'] ?? false,
      isNewArrival: map['isNewArrival'] ?? false,
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    String? category,
    List<String>? images,
    List<String>? sizes,
    List<String>? colors,
    int? stockQuantity,
    bool? isFeatured,
    bool? isNewArrival,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      category: category ?? this.category,
      images: images ?? this.images,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isFeatured: isFeatured ?? this.isFeatured,
      isNewArrival: isNewArrival ?? this.isNewArrival,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, price: $price, category: $category)';
  }
}