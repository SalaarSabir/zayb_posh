import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/address_model.dart';
class AddressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _addressCollection => _firestore.collection('addresses');
  Stream<List<AddressModel>> getUserAddressesStream(String userId) {
    return _addressCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AddressModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
  Future<String> addAddress(AddressModel address) async {
    try {
      final docRef = _addressCollection.doc();
      final addressId = docRef.id;
      if (address.isDefault) {
        await _unsetOtherDefaults(address.userId);
      }

      final addressWithId = address.copyWith(
        id: addressId,
        createdAt: DateTime.now(),
      );

      await docRef.set(addressWithId.toMap());
      return addressId;
    } catch (e) {
      throw 'Failed to add address: $e';
    }
  }
  Future<void> updateAddress(AddressModel address) async {
    try {
      if (address.isDefault) {
        await _unsetOtherDefaults(address.userId, exceptId: address.id);
      }

      await _addressCollection.doc(address.id).update(address.toMap());
    } catch (e) {
      throw 'Failed to update address: $e';
    }
  }
  Future<void> deleteAddress(String addressId) async {
    try {
      await _addressCollection.doc(addressId).delete();
    } catch (e) {
      throw 'Failed to delete address: $e';
    }
  }
  Future<void> setAsDefault(String userId, String addressId) async {
    try {
      await _unsetOtherDefaults(userId, exceptId: addressId);
      await _addressCollection.doc(addressId).update({'isDefault': true});
    } catch (e) {
      throw 'Failed to set default address: $e';
    }
  }
  Future<AddressModel?> getDefaultAddress(String userId) async {
    try {
      final snapshot = await _addressCollection
          .where('userId', isEqualTo: userId)
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return AddressModel.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  Future<void> _unsetOtherDefaults(String userId, {String? exceptId}) async {
    try {
      final snapshot = await _addressCollection
          .where('userId', isEqualTo: userId)
          .where('isDefault', isEqualTo: true)
          .get();

      for (var doc in snapshot.docs) {
        if (exceptId == null || doc.id != exceptId) {
          await doc.reference.update({'isDefault': false});
        }
      }
    } catch (e) {
    }
  }
}