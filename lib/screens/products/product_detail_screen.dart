import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/helpers.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/common/custom_button.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? selectedSize;
  String? selectedColor;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    if (widget.product.sizes.isNotEmpty) {
      selectedSize = widget.product.sizes.first;
    }
    if (widget.product.colors.isNotEmpty) {
      selectedColor = widget.product.colors.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(AppStrings.productDetails),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 400,
                    width: double.infinity,
                    color: AppColors.grey100,
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 100,
                            color: AppColors.grey300,
                          ),
                        ),
                        if (widget.product.hasDiscount)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${widget.product.discountPercentage}% OFF',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, color: AppColors.rating, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              widget.product.rating.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${widget.product.reviewCount} ${AppStrings.reviews})',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Text(
                              Helpers.formatCurrency(widget.product.price),
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            if (widget.product.hasDiscount) ...[
                              const SizedBox(width: 12),
                              Text(
                                Helpers.formatCurrency(widget.product.originalPrice!),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 24),
                        if (widget.product.sizes.isNotEmpty) ...[
                          Text(
                            AppStrings.size,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.product.sizes.map((size) {
                              final isSelected = selectedSize == size;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedSize = size;
                                  });
                                },
                                child: Container(
                                  width: 60,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary : AppColors.white,
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : AppColors.grey300,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      size,
                                      style: TextStyle(
                                        color: isSelected ? AppColors.white : AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (widget.product.colors.isNotEmpty) ...[
                          Text(
                            AppStrings.color,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.product.colors.map((color) {
                              final isSelected = selectedColor == color;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedColor = color;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary : AppColors.white,
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : AppColors.grey300,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    color,
                                    style: TextStyle(
                                      color: isSelected ? AppColors.white : AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],
                        Text(
                          AppStrings.description,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.product.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Icon(
                              widget.product.isInStock
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: widget.product.isInStock
                                  ? AppColors.success
                                  : AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.product.isInStock
                                  ? '${AppStrings.inStock} (${widget.product.stockQuantity})'
                                  : AppStrings.outOfStock,
                              style: TextStyle(
                                color: widget.product.isInStock
                                    ? AppColors.success
                                    : AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: AppStrings.addToCart,
                    icon: Icons.shopping_bag_outlined,
                    onPressed: widget.product.isInStock
                        ? () {
                      final cart = Provider.of<CartProvider>(
                        context,
                        listen: false,
                      );

                      cart.addToCart(
                        product: widget.product,
                        selectedSize: selectedSize ?? '',
                        selectedColor: selectedColor ?? '',
                        quantity: quantity,
                      );

                      Helpers.showSnackBar(
                        context,
                        AppStrings.productAddedToCart,
                      );
                    }
                        : () {},
                    backgroundColor: widget.product.isInStock
                        ? AppColors.primary
                        : AppColors.grey300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}