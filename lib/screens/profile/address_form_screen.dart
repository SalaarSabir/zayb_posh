import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/validators.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/address_model.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';

class AddressFormScreen extends StatefulWidget {
  final AddressModel? address;

  const AddressFormScreen({super.key, this.address});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _postalCodeController;
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.address?.name ?? '');
    _phoneController = TextEditingController(text: widget.address?.phone ?? '');
    _addressController = TextEditingController(text: widget.address?.address ?? '');
    _cityController = TextEditingController(text: widget.address?.city ?? '');
    _stateController = TextEditingController(text: widget.address?.state ?? '');
    _postalCodeController = TextEditingController(text: widget.address?.postalCode ?? '');
    _isDefault = widget.address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<AddressProvider>(context, listen: false);

    final address = AddressModel(
      id: widget.address?.id ?? '',
      userId: auth.user!.uid,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      isDefault: _isDefault,
      createdAt: widget.address?.createdAt ?? DateTime.now(),
    );

    final success = widget.address == null
        ? await provider.addAddress(address)
        : await provider.updateAddress(address);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      Helpers.showSnackBar(context, widget.address == null ? 'Address added' : 'Address updated');
      Navigator.pop(context);
    } else {
      Helpers.showSnackBar(context, 'Failed to save address', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(widget.address == null ? 'Add Address' : 'Edit Address'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                hintText: 'Enter your name',
                prefixIcon: Icons.person_outline,
                validator: Validators.validateName,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hintText: 'Enter phone number',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: Validators.validatePhone,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _addressController,
                label: 'Address',
                hintText: 'House no, Street name',
                maxLines: 2,
                prefixIcon: Icons.location_on_outlined,
                validator: (v) => Validators.validateRequired(v, 'Address'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _cityController,
                label: 'City',
                hintText: 'Enter city',
                prefixIcon: Icons.location_city,
                validator: (v) => Validators.validateRequired(v, 'City'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _stateController,
                      label: 'State',
                      hintText: 'Enter state',
                      validator: (v) => Validators.validateRequired(v, 'State'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _postalCodeController,
                      label: 'Postal Code',
                      hintText: '12345',
                      keyboardType: TextInputType.number,
                      validator: Validators.validatePostalCode,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v ?? false),
                title: const Text('Set as default address'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: widget.address == null ? 'Add Address' : 'Update Address',
                isLoading: _isLoading,
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}