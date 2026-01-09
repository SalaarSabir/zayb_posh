import 'package:flutter/material.dart';
import '../core/services/address_service.dart';
import '../models/address_model.dart';

class AddressProvider with ChangeNotifier {
  final AddressService _addressService = AddressService();

  List<AddressModel> _addresses = [];
  final bool _isLoading = false;

  List<AddressModel> get addresses => _addresses;
  bool get isLoading => _isLoading;
  bool get hasAddresses => _addresses.isNotEmpty;

  void initializeAddresses(String userId) {
    _addressService.getUserAddressesStream(userId).listen((addresses) {
      _addresses = addresses;
      notifyListeners();
    });
  }

  Future<bool> addAddress(AddressModel address) async {
    try {
      await _addressService.addAddress(address);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateAddress(AddressModel address) async {
    try {
      await _addressService.updateAddress(address);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteAddress(String addressId) async {
    try {
      await _addressService.deleteAddress(addressId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> setAsDefault(String userId, String addressId) async {
    try {
      await _addressService.setAsDefault(userId, addressId);
      return true;
    } catch (e) {
      return false;
    }
  }

  AddressModel? get defaultAddress {
    try {
      return _addresses.firstWhere((addr) => addr.isDefault);
    } catch (e) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }
}