import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/hive_storage_service.dart';
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
            color: AppColors.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 70,
              height: 70,
              color: AppColors.grey100,
              child: cartItem.product.images.isNotEmpty
                  ? HiveStorageService.base64ToImage(
                HiveStorageService.getProductImage(
                    cartItem.product.images.first) ??
                    '',
                fit: BoxFit.cover,
              )
                  : const Icon(
                Icons.image_outlined,
                size: 28,
                color: AppColors.grey300,
              ),
            ),
          ),

          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        cartItem.product.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: onRemove,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Size: ${cartItem.selectedSize}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        cartItem.selectedColor,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Helpers.formatCurrency(cartItem.product.price),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    if (cartItem.product.hasDiscount)
                      Text(
                        Helpers.formatCurrency(
                            cartItem.product.originalPrice!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.textLight,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey300),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: onDecrease,
                            child: Container(
                              padding: const EdgeInsets.all(6),
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
                          Container(
                            constraints: const BoxConstraints(minWidth: 28),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              '${cartItem.quantity}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          InkWell(
                            onTap: onIncrease,
                            child: Container(
                              padding: const EdgeInsets.all(6),
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

                    const Spacer(),
                    Text(
                      'Total: ${Helpers.formatCurrency(cartItem.totalPrice)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}