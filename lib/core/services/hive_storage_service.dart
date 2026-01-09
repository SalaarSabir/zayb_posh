import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'dart:convert';

class HiveStorageService {
  static const String _productImagesBox = 'product_images';
  static const String _profilePicturesBox = 'profile_pictures';
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_productImagesBox);
    await Hive.openBox(_profilePicturesBox);
  }
  static Future<String> saveProductImage(File imageFile, String productId) async {
    try {
      final box = Hive.box(_productImagesBox);
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);

      final imageKey = 'product_$productId';
      await box.put(imageKey, base64String);

      return imageKey;
    } catch (e) {
      throw 'Failed to save image: $e';
    }
  }
  static String? getProductImage(String imageKey) {
    try {
      final box = Hive.box(_productImagesBox);
      return box.get(imageKey);
    } catch (e) {
      return null;
    }
  }
  static Future<void> deleteProductImage(String imageKey) async {
    try {
      final box = Hive.box(_productImagesBox);
      await box.delete(imageKey);
    } catch (e) {
      // Ignore
    }
  }
  static Future<String> saveProfilePicture(File imageFile, String userId) async {
    try {
      final box = Hive.box(_profilePicturesBox);
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);

      final imageKey = 'profile_$userId';
      await box.put(imageKey, base64String);

      return imageKey; // Return key as "URL"
    } catch (e) {
      throw 'Failed to save profile picture: $e';
    }
  }
  static String? getProfilePicture(String imageKey) {
    try {
      final box = Hive.box(_profilePicturesBox);
      return box.get(imageKey);
    } catch (e) {
      return null;
    }
  }
  static Future<void> deleteProfilePicture(String imageKey) async {
    try {
      final box = Hive.box(_profilePicturesBox);
      await box.delete(imageKey);
    } catch (e) {
      // Ignore
    }
  }
  static Widget base64ToImage(String base64String, {BoxFit fit = BoxFit.cover}) {
    try {
      final bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        fit: fit,
        errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined),
      );
    } catch (e) {
      return const Icon(Icons.image_outlined);
    }
  }
}