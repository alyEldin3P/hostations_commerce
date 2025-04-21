import 'dart:developer' as logger;
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hostations_commerce/core/presentation/cubits/app/app_cubit.dart';
import 'package:hostations_commerce/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:hostations_commerce/features/cart/presentation/cubits/cart_cubit.dart';
import 'package:hostations_commerce/features/cart/presentation/cubits/cart_state.dart';
import 'package:hostations_commerce/features/checkout/presentation/screens/payment_method_screen.dart';
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
      body: MultiBlocListener(
        listeners: [
          BlocListener<CartCubit, CartState>(
            listener: (context, state) {
              if ((state.addressAddSuccess) || (state.status == CartStatus.addressAddSuccess)) {
                Navigator.of(context).pushReplacementNamed(PaymentMethodScreen.routeName);
              } else if ((state.hasError) && !(state.isAddingDeliveryAddress ?? false)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage ?? 'Error adding address')),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<AddressCubit, AddressState>(
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
        child: BlocBuilder<CartCubit, CartState>(
          builder: (context, cartState) {
            final isLoading = cartState.isAddingDeliveryAddress ?? false;
            return AppButton(
              label: isLoading ? 'Adding Address...' : 'Next: Payment Method',
              onPressed: _selectedAddress == null || isLoading
                  ? () {}
                  : () async {
                      final cartId = context.read<CartCubit>().state.cart.id;

                      await context.read<CartCubit>().addDeliveryAddressToCart(
                            cartId: cartId,
                            address: _selectedAddress!,
                          );
                    },
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
