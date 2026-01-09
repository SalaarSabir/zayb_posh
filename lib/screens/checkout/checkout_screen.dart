import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/helpers.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../orders/order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String selectedPaymentMethod = 'Cash on Delivery';
  bool isProcessing = false;

  final List<String> paymentMethods = [
    'Cash on Delivery',
    'Credit/Debit Card',
    'Mobile Wallet',
  ];

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.checkout),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, 'Delivery Address'),
                  const SizedBox(height: 12),
                  _buildAddressCard(
                    context,
                    name: auth.user?.name ?? 'Guest User',
                    email: auth.user?.email ?? 'guest@example.com',
                    phone: auth.user?.phoneNumber ?? '+92 300 1234567',
                    address:
                    'House 123, Street 45, Sector F-7, Islamabad, Pakistan',
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle(context, AppStrings.orderSummary),
                  const SizedBox(height: 12),
                  _buildOrderSummaryCard(context, cart),

                  const SizedBox(height: 24),
                  _buildSectionTitle(context, AppStrings.paymentMethod),
                  const SizedBox(height: 12),
                  _buildPaymentMethodsCard(context),

                  const SizedBox(height: 24),
                  _buildSectionTitle(
                      context, 'Items (${cart.totalQuantity})'),
                  const SizedBox(height: 12),
                  ...cart.items.map((item) => _buildOrderItemCard(
                    context,
                    item.product.name,
                    '${item.selectedSize} | ${item.selectedColor}',
                    item.quantity,
                    item.totalPrice,
                  )),
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      Helpers.formatCurrency(cart.total),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: AppStrings.placeOrder,
                  isLoading: isProcessing,
                  onPressed: () => _handlePlaceOrder(context, cart),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildAddressCard(
      BuildContext context, {
        required String name,
        required String email,
        required String phone,
        required String address,
      }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Edit address
                },
                child: const Text('Change'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.email_outlined, size: 16),
              const SizedBox(width: 8),
              Text(
                email,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 16),
              const SizedBox(width: 8),
              Text(
                phone,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          _buildSummaryRow(context, AppStrings.subtotal,
              Helpers.formatCurrency(cart.subtotal)),
          const SizedBox(height: 8),
          _buildSummaryRow(
            context,
            AppStrings.shipping,
            cart.shippingCost == 0
                ? 'FREE'
                : Helpers.formatCurrency(cart.shippingCost),
            valueColor: cart.shippingCost == 0 ? AppColors.success : null,
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
              context, AppStrings.tax, Helpers.formatCurrency(cart.tax)),
          const Divider(height: 24),
          _buildSummaryRow(
            context,
            AppStrings.total,
            Helpers.formatCurrency(cart.total),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: paymentMethods.map((method) {
          final isSelected = selectedPaymentMethod == method;
          return RadioListTile<String>(
            value: method,
            groupValue: selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                selectedPaymentMethod = value!;
              });
            },
            title: Text(
              method,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            activeColor: AppColors.primary,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrderItemCard(
      BuildContext context,
      String name,
      String variant,
      int quantity,
      double price,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  variant,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'x$quantity',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: Text(
              Helpers.formatCurrency(price),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: valueColor ??
                (isTotal ? AppColors.primary : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Future<void> _handlePlaceOrder(
      BuildContext context, CartProvider cart) async {
    setState(() {
      isProcessing = true;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    try {
      await orderProvider.placeOrder(
        userId: auth.user?.uid ?? 'guest',
        items: cart.items,
        subtotal: cart.subtotal,
        shippingCost: cart.shippingCost,
        tax: cart.tax,
        total: cart.total,
        paymentMethod: selectedPaymentMethod,
        deliveryName: auth.user?.name ?? 'Guest User',
        deliveryPhone: auth.user?.phoneNumber ?? '+92 300 1234567',
        deliveryAddress: 'House 123, Street 45, Sector F-7, Islamabad, Pakistan',
      );
      cart.clearCart();

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const OrderSuccessScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isProcessing = false;
      });

      Helpers.showSnackBar(
        context,
        'Failed to place order. Please try again.',
        isError: true,
      );
    }
  }
}