import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _wishlistCollection => _firestore.collection('wishlists');

  Stream<List<String>> getUserWishlistStream(String userId) {
    return _wishlistCollection
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        return List<String>.from(data['productIds'] ?? []);
      }
      return [];
    });
  }
  Future<void> addToWishlist(String userId, String productId) async {
    try {
      final doc = await _wishlistCollection.doc(userId).get();

      if (doc.exists) {
        await _wishlistCollection.doc(userId).update({
          'productIds': FieldValue.arrayUnion([productId]),
          'updatedAt': DateTime.now().toIso8601String(),
        });
      } else {
        await _wishlistCollection.doc(userId).set({
          'userId': userId,
          'productIds': [productId],
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw 'Failed to add to wishlist: $e';
    }
  }
  Future<void> removeFromWishlist(String userId, String productId) async {
    try {
      await _wishlistCollection.doc(userId).update({
        'productIds': FieldValue.arrayRemove([productId]),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Failed to remove from wishlist: $e';
    }
  }
  Future<void> clearWishlist(String userId) async {
    try {
      await _wishlistCollection.doc(userId).delete();
    } catch (e) {
      throw 'Failed to clear wishlist: $e';
    }
  }
  Future<bool> isInWishlist(String userId, String productId) async {
    try {
      final doc = await _wishlistCollection.doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final productIds = List<String>.from(data['productIds'] ?? []);
        return productIds.contains(productId);
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}