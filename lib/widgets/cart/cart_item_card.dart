// lib/widgets/cart/cart_item_card.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/cart_model.dart';

class CartItemCard extends StatelessWidget {
  final CartItemModel cartItem;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.cartItem,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                Icons.image_outlined,
                size: 32,
                color: AppColors.grey300,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  cartItem.product.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Size & Color
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Size: ${cartItem.selectedSize}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        cartItem.selectedColor,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Price & Quantity
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Helpers.formatCurrency(cartItem.product.price),
                          style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        if (cartItem.product.hasDiscount)
                          Text(
                            Helpers.formatCurrency(
                                cartItem.product.originalPrice!),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.textLight,
                            ),
                          ),
                      ],
                    ),

                    // Quantity Controls
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          // Decrease Button
                          InkWell(
                            onTap: onDecrease,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                cartItem.quantity == 1
                                    ? Icons.delete_outline
                                    : Icons.remove,
                                size: 16,
                                color: cartItem.quantity == 1
                                    ? AppColors.error
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),

                          // Quantity
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '${cartItem.quantity}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // Increase Button
                          InkWell(
                            onTap: onIncrease,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.add,
                                size: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Total Price for this item
                Text(
                  'Total: ${Helpers.formatCurrency(cartItem.totalPrice)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Remove Button
          IconButton(
            icon: const Icon(
              Icons.close,
              size: 20,
              color: AppColors.textSecondary,
            ),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}