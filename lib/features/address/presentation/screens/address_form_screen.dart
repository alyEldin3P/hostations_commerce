import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hostations_commerce/core/presentation/cubits/app/app_cubit.dart';
import 'package:hostations_commerce/features/address/presentation/cubits/address_state.dart';
import '../cubits/address_cubit.dart';
import '../../data/model/address.dart';
import 'dart:developer';
import 'package:hostations_commerce/features/address/data/model/country_state_data.dart';

class AddressFormScreen extends StatefulWidget {
  final Address? initialAddress;
  const AddressFormScreen({Key? key, this.initialAddress}) : super(key: key);

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late Address _address;
  late AppCubit _appCubit;

  @override
  void initState() {
    super.initState();
    _address = widget.initialAddress ?? Address.sample();
    _appCubit = context.read<AppCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.initialAddress == null ? 'Add Address' : 'Edit Address')),
      body: BlocListener<AddressCubit, AddressState>(
        listener: (context, state) {
          if (state.status == AddressStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error ?? 'Failed to save address'), backgroundColor: Colors.red),
            );
          } else if (state.status == AddressStatus.success) {
            Navigator.pop(context); // Return true to indicate change
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  initialValue: _address.name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  onChanged: (v) => _address = _address.copyWith(name: v),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  initialValue: _address.phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  onChanged: (v) => _address = _address.copyWith(phone: v),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  initialValue: _address.address1,
                  decoration: const InputDecoration(labelText: 'Address 1'),
                  onChanged: (v) => _address = _address.copyWith(address1: v),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  initialValue: _address.address2,
                  decoration: const InputDecoration(labelText: 'Address 2'),
                  onChanged: (v) => _address = _address.copyWith(address2: v),
                ),
                TextFormField(
                  initialValue: _address.city,
                  decoration: const InputDecoration(labelText: 'City'),
                  onChanged: (v) => _address = _address.copyWith(city: v),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                DropdownButtonFormField<String>(
                  value: supportedCountries.contains(_address.country) ? _address.country : null,
                  decoration: const InputDecoration(labelText: 'Country'),
                  items: supportedCountries.map((country) => DropdownMenuItem(value: country, child: Text(country))).toList(),
                  onChanged: (v) {
                    setState(() {
                      _address = _address.copyWith(country: v, state: '');
                    });
                  },
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                DropdownButtonFormField<String>(
                  value: countryToStates[_address.country]?.contains(_address.state) == true ? _address.state : null,
                  decoration: const InputDecoration(labelText: 'State/Province'),
                  items: (countryToStates[_address.country] ?? []).map((state) => DropdownMenuItem(value: state, child: Text(state))).toList(),
                  onChanged: (v) => setState(() => _address = _address.copyWith(state: v)),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  initialValue: _address.zip,
                  decoration: const InputDecoration(labelText: 'ZIP'),
                  onChanged: (v) => _address = _address.copyWith(zip: v),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                SwitchListTile(
                  value: _address.isDefault,
                  onChanged: (v) => setState(() => _address = _address.copyWith(isDefault: v)),
                  title: const Text('Default Address'),
                ),
                const SizedBox(height: 24),
                BlocBuilder<AddressCubit, AddressState>(
                  builder: (context, state) {
                    log('[AddressForm] BlocBuilder status: ${state.status}');
                    return ElevatedButton(
                      onPressed: state.status == AddressStatus.loading
                          ? null
                          : () {
                              log('[AddressForm] Submit button pressed. Address: ${_address.toJson()}');
                              if (_formKey.currentState!.validate()) {
                                log('[AddressForm] Form is valid. ${widget.initialAddress == null ? 'Creating' : 'Editing'} address...');
                                if (widget.initialAddress == null) {
                                  context.read<AddressCubit>().createAddress(_address, _appCubit.state.isGuest);
                                } else {
                                  context.read<AddressCubit>().editAddress(_address, _appCubit.state.isGuest);
                                }
                              } else {
                                log('[AddressForm] Form validation failed.');
                              }
                            },
                      child: state.status == AddressStatus.loading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(widget.initialAddress == null ? 'Add' : 'Save'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
