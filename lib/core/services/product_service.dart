import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/product_model.dart';
import '../services/hive_storage_service.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference get _productsCollection =>
      _firestore.collection('products');
  Stream<List<ProductModel>> getProductsStream() {
    return _productsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
  Stream<List<ProductModel>> getProductsByCategory(String category) {
    return _productsCollection
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
  Stream<List<ProductModel>> getFeaturedProducts() {
    return _productsCollection
        .where('isFeatured', isEqualTo: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
  Stream<List<ProductModel>> getNewArrivals() {
    return _productsCollection
        .where('isNewArrival', isEqualTo: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
  Future<String> uploadProductImage(File imageFile, String productId) async {
    try {
      return await HiveStorageService.saveProductImage(imageFile, productId);
    } catch (e) {
      throw 'Failed to save image: $e';
    }
  }
  Future<void> deleteProductImage(String imageKey) async {
    try {
      await HiveStorageService.deleteProductImage(imageKey);
    } catch (e) {
      // Ignore
    }
  }
  Future<String> addProduct(ProductModel product, {File? imageFile}) async {
    try {
      final docRef = _productsCollection.doc();
      final productId = docRef.id;
      String? imageKey;
      if (imageFile != null) {
        imageKey = await uploadProductImage(imageFile, productId);
      }
      final newProduct = product.copyWith(
        id: productId,
        images: imageKey != null ? [imageKey] : [],
        createdAt: DateTime.now(),
      );
      await docRef.set(newProduct.toMap());

      return productId;
    } catch (e) {
      throw 'Failed to add product: $e';
    }
  }
  Future<void> updateProduct(ProductModel product, {File? newImageFile}) async {
    try {
      String? imageKey;
      if (newImageFile != null) {
        if (product.images.isNotEmpty) {
          await deleteProductImage(product.images.first);
        }
        imageKey = await uploadProductImage(newImageFile, product.id);
      }
      final updatedProduct = product.copyWith(
        images: imageKey != null ? [imageKey] : product.images,
      );

      await _productsCollection.doc(product.id).update(updatedProduct.toMap());
    } catch (e) {
      throw 'Failed to update product: $e';
    }
  }
  Future<void> deleteProduct(String productId) async {
    try {
      final doc = await _productsCollection.doc(productId).get();
      if (doc.exists) {
        final product = ProductModel.fromMap(doc.data() as Map<String, dynamic>);
        for (final imageKey in product.images) {
          await deleteProductImage(imageKey);
        }
      }
      await _productsCollection.doc(productId).delete();
    } catch (e) {
      throw 'Failed to delete product: $e';
    }
  }
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final snapshot = await _productsCollection.get();
      final products = snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      final lowercaseQuery = query.toLowerCase();
      return products.where((product) {
        return product.name.toLowerCase().contains(lowercaseQuery) ||
            product.description.toLowerCase().contains(lowercaseQuery) ||
            product.category.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      throw 'Failed to search products: $e';
    }
  }
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc = await _productsCollection.doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw 'Failed to get product: $e';
    }
  }
  Future<Map<String, int>> getCategoriesWithCount() async {
    try {
      final snapshot = await _productsCollection.get();
      final products = snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      final Map<String, int> categoryCount = {};
      for (final product in products) {
        categoryCount[product.category] = (categoryCount[product.category] ?? 0) + 1;
      }

      return categoryCount;
    } catch (e) {
      throw 'Failed to get categories: $e';
    }
  }
}
