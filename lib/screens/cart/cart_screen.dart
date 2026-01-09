import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/helpers.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/cart/cart_item_card.dart';
import '../../widgets/common/custom_button.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.cart),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              if (cart.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: () {
                  _showClearCartDialog(context, cart);
                },
                child: const Text('Clear All'),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: AppColors.grey300,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppStrings.cartEmpty,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add products to your cart',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: const Text(AppStrings.continueShopping),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final cartItem = cart.items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CartItemCard(
                        cartItem: cartItem,
                        onIncrease: () => cart.increaseQuantity(cartItem.id),
                        onDecrease: () => cart.decreaseQuantity(cartItem.id),
                        onRemove: () => cart.removeFromCart(cartItem.id),
                      ),
                    );
                  },
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
                child: Column(
                  children: [
                    _buildSummaryRow(
                      context,
                      AppStrings.subtotal,
                      Helpers.formatCurrency(cart.subtotal),
                    ),
                    const SizedBox(height: 8),

                    _buildSummaryRow(
                      context,
                      AppStrings.shipping,
                      cart.shippingCost == 0
                          ? 'FREE'
                          : Helpers.formatCurrency(cart.shippingCost),
                      valueColor:
                      cart.shippingCost == 0 ? AppColors.success : null,
                    ),
                    const SizedBox(height: 8),

                    _buildSummaryRow(
                      context,
                      AppStrings.tax,
                      Helpers.formatCurrency(cart.tax),
                    ),

                    const Divider(height: 24),

                    _buildSummaryRow(
                      context,
                      AppStrings.total,
                      Helpers.formatCurrency(cart.total),
                      isTotal: true,
                    ),

                    const SizedBox(height: 16),
                    CustomButton(
                      text: AppStrings.proceedToCheckout,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CheckoutScreen(),
                          ),
                        );
                      },
                    ),
                    if (cart.subtotal < 5000) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.local_shipping_outlined,
                              color: AppColors.info,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Add ${Helpers.formatCurrency(5000 - cart.subtotal)} more for FREE shipping!',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                  color: AppColors.info,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(
      BuildContext context,
      String label,
      String value, {
        bool isTotal = false,
        Color? valueColor,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: valueColor ??
                (isTotal ? AppColors.primary : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  void _showClearCartDialog(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              cart.clearCart();
              Navigator.pop(context);
              Helpers.showSnackBar(context, 'Cart cleared');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}