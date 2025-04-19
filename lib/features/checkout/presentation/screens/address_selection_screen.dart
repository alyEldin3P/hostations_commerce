import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hostations_commerce/core/presentation/cubits/app/app_cubit.dart';
import 'package:hostations_commerce/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:hostations_commerce/features/cart/presentation/cubits/cart_cubit.dart';
import 'package:hostations_commerce/features/cart/presentation/cubits/shipping_method_cubit.dart';
import 'package:hostations_commerce/features/cart/presentation/screens/select_shipping_method_screen.dart';
import 'package:hostations_commerce/widgets/app_widgets.dart';
import '../../../address/presentation/cubits/address_cubit.dart';
import '../../../address/presentation/cubits/address_state.dart';
import '../../../address/data/model/address.dart';
import '../../../address/presentation/screens/address_form_screen.dart';

class AddressSelectionScreen extends StatefulWidget {
  const AddressSelectionScreen({Key? key}) : super(key: key);

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  late AppCubit _appCubit;
  late AuthCubit _authCubit;
  late AddressCubit _addressCubit;
  Address? _selectedAddress;

  String getCountryCode(String country) {
    const countryMap = {
      'United States': 'US',
      'USA': 'US',
      'Egypt': 'EG',
      'Canada': 'CA',
      // Add more as needed
    };
    return countryMap[country] ?? country;
  }

  @override
  void initState() {
    super.initState();
    _appCubit = context.read<AppCubit>();
    _addressCubit = context.read<AddressCubit>();
    _authCubit = context.read<AuthCubit>();
    // Fetch addresses
    Future.microtask(() => _addressCubit.fetchAllAddresses(_appCubit.state.isGuest));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const AppText('Select Address')),
      body: BlocBuilder<AddressCubit, AddressState>(
        builder: (context, state) {
          if (state.status == AddressStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == AddressStatus.failure) {
            return Center(child: AppText('Error: ${state.error}'));
          } else if (state.addresses.isEmpty) {
            return const Center(child: AppText('No addresses found.'));
          }
          return ListView.builder(
            itemCount: state.addresses.length,
            itemBuilder: (context, index) {
              final address = state.addresses[index];
              return Card(
                child: RadioListTile<Address>(
                  title: AppText(address.name),
                  subtitle: AppText(address.address1),
                  value: address,
                  groupValue: _selectedAddress,
                  onChanged: (value) {
                    setState(() {
                      _selectedAddress = value;
                    });
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: AppButton(
        label: 'Add Address',
        icon: Icons.add,
        onPressed: () async {
          final newAddress = await Navigator.push<Address>(
            context,
            MaterialPageRoute(builder: (context) => const AddressFormScreen()),
          );
          if (newAddress != null) {
            context.read<AddressCubit>().fetchAllAddresses(_appCubit.state.isGuest);
          }
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AppButton(
          label: 'Next: Shipping Method',
          onPressed: _selectedAddress == null
              ? () {}
              : () async {
                  final cartId = context.read<CartCubit>().state.cart.id;
                  final address = _selectedAddress!;
                  log('Selected country: ${address.country}');
                  // Convert Address model to Shopify-compatible map
                  final addressMap = {
                    'countryCode': getCountryCode(address.country),
                    // 'phone': address.phone,
                    // 'email': _authCubit.state.user?.email,
                  };
                  await context.read<ShippingMethodCubit>().updateCartBuyerIdentity(
                        cartId: cartId,
                        address: addressMap,
                      );
                  // After address is set, proceed to shipping method selection
                  final selectedMethod = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelectShippingMethodScreen(cartId: cartId),
                    ),
                  );
                  if (selectedMethod != null) {
                    final cart = context.read<CartCubit>().state.cart;
                    final deliveryGroupId = cart.deliveryGroups?.first.id;
                    if (deliveryGroupId != null) {
                      context.read<ShippingMethodCubit>().repository.setShippingMethod(
                            cartId: cart.id,
                            deliveryGroupId: deliveryGroupId,
                            shippingHandle: selectedMethod.id,
                          );
                    }
                  }
                },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
