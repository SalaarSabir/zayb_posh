import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/helpers.dart';
import '../../models/order_model.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.orderDetails),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status Card
            _buildStatusCard(context),

            const SizedBox(height: 16),

            _buildInfoCard(
              context,
              title: 'Order Information',
              children: [
                _buildInfoRow(context, 'Order ID', '#${order.id.substring(order.id.length - 8)}',
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: order.id));
                    Helpers.showSnackBar(context, 'Order ID copied');
                  },
                ),
                const Divider(height: 20),
                _buildInfoRow(context, 'Order Date', Helpers.formatDate(order.createdAt)),
                const Divider(height: 20),
                _buildInfoRow(context, 'Payment Method', order.paymentMethod),
                if (order.trackingNumber != null) ...[
                  const Divider(height: 20),
                  _buildInfoRow(context, 'Tracking Number', order.trackingNumber!),
                ],
              ],
            ),

            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              title: 'Delivery Information',
              children: [
                _buildInfoRow(context, 'Name', order.deliveryName),
                const Divider(height: 20),
                _buildInfoRow(context, 'Phone', order.deliveryPhone),
                const Divider(height: 20),
                _buildInfoRow(context, 'Address', order.deliveryAddress),
                if (order.status == OrderStatus.delivered && order.deliveredAt != null) ...[
                  const Divider(height: 20),
                  _buildInfoRow(context, 'Delivered On', Helpers.formatDate(order.deliveredAt!)),
                ],
              ],
            ),

            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              title: 'Order Summary',
              children: [
                _buildPriceRow(context, AppStrings.subtotal, order.subtotal),
                const SizedBox(height: 12),
                _buildPriceRow(
                  context,
                  AppStrings.shipping,
                  order.shippingCost,
                  isFree: order.shippingCost == 0,
                ),
                const SizedBox(height: 12),
                _buildPriceRow(context, AppStrings.tax, order.tax),
                const Divider(height: 24),
                _buildPriceRow(
                  context,
                  AppStrings.total,
                  order.total,
                  isTotal: true,
                ),
              ],
            ),

            const SizedBox(height: 16),
            if (order.status != OrderStatus.cancelled) _buildTimelineCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (order.status) {
      case OrderStatus.pending:
        statusColor = AppColors.warning;
        statusIcon = Icons.access_time;
        break;
      case OrderStatus.confirmed:
      case OrderStatus.processing:
        statusColor = AppColors.info;
        statusIcon = Icons.check_circle_outline;
        break;
      case OrderStatus.shipped:
        statusColor = AppColors.secondary;
        statusIcon = Icons.local_shipping_outlined;
        break;
      case OrderStatus.delivered:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case OrderStatus.cancelled:
        statusColor = AppColors.error;
        statusIcon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              color: AppColors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Status',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.statusText,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          if (onTap != null)
            const Icon(Icons.copy, size: 16, color: AppColors.textLight),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
      BuildContext context,
      String label,
      double amount, {
        bool isTotal = false,
        bool isFree = false,
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
          isFree ? 'FREE' : Helpers.formatCurrency(amount),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal
                ? AppColors.primary
                : isFree
                ? AppColors.success
                : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Timeline',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildTimelineItem(
            context,
            'Order Placed',
            Helpers.formatDateTime(order.createdAt),
            isCompleted: true,
          ),
          _buildTimelineItem(
            context,
            'Order Confirmed',
            'Processing your order',
            isCompleted: order.status.index >= OrderStatus.confirmed.index,
          ),
          _buildTimelineItem(
            context,
            'Shipped',
            'On the way',
            isCompleted: order.status.index >= OrderStatus.shipped.index,
          ),
          _buildTimelineItem(
            context,
            'Delivered',
            order.deliveredAt != null
                ? Helpers.formatDateTime(order.deliveredAt!)
                : 'Estimated 3-5 days',
            isCompleted: order.status == OrderStatus.delivered,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
      BuildContext context,
      String title,
      String subtitle, {
        required bool isCompleted,
        bool isLast = false,
      }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.success : AppColors.grey300,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.circle,
                color: AppColors.white,
                size: 14,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? AppColors.success : AppColors.grey300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}