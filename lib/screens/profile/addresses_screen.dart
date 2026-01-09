import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/address_model.dart';
import 'address_form_screen.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user != null) {
        Provider.of<AddressProvider>(context, listen: false)
            .initializeAddresses(auth.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Addresses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddForm(context, null),
          ),
        ],
      ),
      body: Consumer<AddressProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!provider.hasAddresses) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on_outlined, size: 100, color: AppColors.grey300),
                  const SizedBox(height: 24),
                  const Text('No addresses yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToAddForm(context, null),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Address'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.addresses.length,
            itemBuilder: (context, index) {
              final address = provider.addresses[index];
              return _buildAddressCard(context, address);
            },
          );
        },
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, AddressModel address) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<AddressProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: address.isDefault ? AppColors.primary : AppColors.grey200,
          width: address.isDefault ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  address.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              if (address.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Default', style: TextStyle(color: AppColors.white, fontSize: 10)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(address.phone),
          const SizedBox(height: 4),
          Text(address.fullAddress, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          Row(
            children: [
              if (!address.isDefault)
                TextButton.icon(
                  onPressed: () => provider.setAsDefault(auth.user!.uid, address.id),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Set Default'),
                ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () => _navigateToAddForm(context, address),
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20, color: AppColors.error),
                onPressed: () => _showDeleteDialog(context, address),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToAddForm(BuildContext context, AddressModel? address) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddressFormScreen(address: address),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, AddressModel address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<AddressProvider>(context, listen: false);
              await provider.deleteAddress(address.id);
              if (!context.mounted) return;
              Navigator.pop(context);
              Helpers.showSnackBar(context, 'Address deleted');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}