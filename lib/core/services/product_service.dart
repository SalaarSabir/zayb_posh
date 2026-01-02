// lib/core/services/product_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection reference
  CollectionReference get _productsCollection =>
      _firestore.collection('products');

  // Get all products (real-time)
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

  // Get products by category
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

  // Get featured products
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

  // Get new arrivals
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

  // Upload image to Firebase Storage
  Future<String> uploadProductImage(File imageFile, String productId) async {
    try {
      final ref = _storage.ref().child('products/$productId/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload image: $e';
    }
  }

  // Delete image from Firebase Storage
  Future<void> deleteProductImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Ignore if image doesn't exist
    }
  }

  // Add new product
  Future<String> addProduct(ProductModel product, {File? imageFile}) async {
    try {
      // Generate product ID
      final docRef = _productsCollection.doc();
      final productId = docRef.id;

      // Upload image if provided
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await uploadProductImage(imageFile, productId);
      }

      // Create product with image
      final newProduct = product.copyWith(
        id: productId,
        images: imageUrl != null ? [imageUrl] : [],
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await docRef.set(newProduct.toMap());

      return productId;
    } catch (e) {
      throw 'Failed to add product: $e';
    }
  }

  // Update product
  Future<void> updateProduct(ProductModel product, {File? newImageFile}) async {
    try {
      String? imageUrl;

      // Upload new image if provided
      if (newImageFile != null) {
        // Delete old image if exists
        if (product.images.isNotEmpty) {
          await deleteProductImage(product.images.first);
        }
        imageUrl = await uploadProductImage(newImageFile, product.id);
      }

      // Update product
      final updatedProduct = product.copyWith(
        images: imageUrl != null ? [imageUrl] : product.images,
      );

      await _productsCollection.doc(product.id).update(updatedProduct.toMap());
    } catch (e) {
      throw 'Failed to update product: $e';
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      // Get product to delete images
      final doc = await _productsCollection.doc(productId).get();
      if (doc.exists) {
        final product = ProductModel.fromMap(doc.data() as Map<String, dynamic>);

        // Delete images
        for (final imageUrl in product.images) {
          await deleteProductImage(imageUrl);
        }
      }

      // Delete product document
      await _productsCollection.doc(productId).delete();
    } catch (e) {
      throw 'Failed to delete product: $e';
    }
  }

  // Search products
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final snapshot = await _productsCollection.get();
      final products = snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Filter products by query
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

  // Get product by ID
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

  // Get categories with product count
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