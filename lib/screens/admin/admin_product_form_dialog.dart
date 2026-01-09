import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/validators.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';

class AdminProductFormDialog extends StatefulWidget {
  final ProductModel? product;

  const AdminProductFormDialog({
    super.key,
    this.product,
  });

  @override
  State<AdminProductFormDialog> createState() => _AdminProductFormDialogState();
}

class _AdminProductFormDialogState extends State<AdminProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _ratingController = TextEditingController();
  final _reviewCountController = TextEditingController();

  String _selectedCategory = 'T-Shirts';
  final List<String> _categories = [
    'T-Shirts',
    'Jeans',
    'Shoes',
    'Jackets',
    'Accessories',
    'Dresses',
    'Shirts',
    'Pants',
  ];

  List<String> _sizes = [];
  List<String> _colors = [];
  bool _isFeatured = false;
  bool _isNewArrival = false;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _initializeWithProduct(widget.product!);
    } else {
      _ratingController.text = '4.5';
      _reviewCountController.text = '0';
    }
  }

  void _initializeWithProduct(ProductModel product) {
    _nameController.text = product.name;
    _descriptionController.text = product.description;
    _priceController.text = product.price.toString();
    _originalPriceController.text = product.originalPrice?.toString() ?? '';
    _stockController.text = product.stockQuantity.toString();
    _ratingController.text = product.rating.toString();
    _reviewCountController.text = product.reviewCount.toString();
    _selectedCategory = product.category;
    _sizes = List.from(product.sizes);
    _colors = List.from(product.colors);
    _isFeatured = product.isFeatured;
    _isNewArrival = product.isNewArrival;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _stockController.dispose();
    _ratingController.dispose();
    _reviewCountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      Helpers.showSnackBar(context, 'Failed to pick image', isError: true);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_sizes.isEmpty) {
      Helpers.showSnackBar(context, 'Please add at least one size', isError: true);
      return;
    }

    if (_colors.isEmpty) {
      Helpers.showSnackBar(context, 'Please add at least one color', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    final product = ProductModel(
      id: widget.product?.id ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text),
      originalPrice: _originalPriceController.text.isNotEmpty
          ? double.parse(_originalPriceController.text)
          : null,
      category: _selectedCategory,
      images: widget.product?.images ?? [],
      sizes: _sizes,
      colors: _colors,
      stockQuantity: int.parse(_stockController.text),
      isFeatured: _isFeatured,
      isNewArrival: _isNewArrival,
      rating: double.parse(_ratingController.text),
      reviewCount: int.parse(_reviewCountController.text),
      createdAt: widget.product?.createdAt ?? DateTime.now(),
    );

    bool success;
    if (widget.product == null) {
      // Add new product
      success = await productProvider.addProduct(product, imageFile: _selectedImage);
    } else {
      // Update existing product
      success = await productProvider.updateProduct(product, newImageFile: _selectedImage);
    }

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      Helpers.showSnackBar(
        context,
        widget.product == null ? 'Product added successfully' : 'Product updated successfully',
      );
      Navigator.pop(context);
    } else {
      Helpers.showSnackBar(
        context,
        productProvider.errorMessage ?? 'Failed to save product',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.product == null ? 'Add Product' : 'Edit Product',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Picker
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: AppColors.grey100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.grey300),
                            ),
                            child: _selectedImage != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                                : widget.product?.images.isNotEmpty == true
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.product!.images.first,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.add_photo_alternate,
                                  size: 50,
                                  color: AppColors.grey400,
                                ),
                              ),
                            )
                                : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 50,
                                  color: AppColors.grey400,
                                ),
                                SizedBox(height: 8),
                                Text('Tap to add image'),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Product Name
                      CustomTextField(
                        controller: _nameController,
                        label: 'Product Name',
                        hintText: 'Enter product name',
                        validator: (value) => Validators.validateRequired(value, 'Product name'),
                      ),

                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hintText: 'Enter product description',
                        maxLines: 3,
                        validator: (value) => Validators.validateRequired(value, 'Description'),
                      ),

                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCategory,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.grey50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: _categories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value!;
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Price Row
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _priceController,
                              label: 'Price (Rs)',
                              hintText: '0',
                              keyboardType: TextInputType.number,
                              validator: Validators.validatePrice,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              controller: _originalPriceController,
                              label: 'Original Price (Optional)',
                              hintText: '0',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Stock
                      CustomTextField(
                        controller: _stockController,
                        label: 'Stock Quantity',
                        hintText: '0',
                        keyboardType: TextInputType.number,
                        validator: (value) => Validators.validateNumeric(value, 'Stock'),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _ratingController,
                              label: 'Rating',
                              hintText: '4.5',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              controller: _reviewCountController,
                              label: 'Review Count',
                              hintText: '0',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _buildListInput(
                        'Sizes',
                        _sizes,
                        'S, M, L, XL',
                      ),

                      const SizedBox(height: 16),

                      _buildListInput(
                        'Colors',
                        _colors,
                        'Red, Blue, Black',
                      ),

                      const SizedBox(height: 16),

                      CheckboxListTile(
                        title: const Text('Featured Product'),
                        value: _isFeatured,
                        onChanged: (value) {
                          setState(() {
                            _isFeatured = value ?? false;
                          });
                        },
                        activeColor: AppColors.primary,
                      ),

                      CheckboxListTile(
                        title: const Text('New Arrival'),
                        value: _isNewArrival,
                        onChanged: (value) {
                          setState(() {
                            _isNewArrival = value ?? false;
                          });
                        },
                        activeColor: AppColors.primary,
                      ),

                      const SizedBox(height: 24),

                      CustomButton(
                        text: widget.product == null ? 'Add Product' : 'Update Product',
                        isLoading: _isLoading,
                        onPressed: _handleSubmit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListInput(String label, List<String> list, String hint) {
    final controller = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                  filled: true,
                  fillColor: AppColors.grey50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      list.add(value.trim());
                    });
                    controller.clear();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    list.add(controller.text.trim());
                  });
                  controller.clear();
                }
              },
              color: AppColors.primary,
            ),
          ],
        ),
        if (list.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: list.map((item) {
              return Chip(
                label: Text(item),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    list.remove(item);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}