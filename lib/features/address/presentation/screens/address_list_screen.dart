import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hostations_commerce/core/presentation/cubits/app/app_cubit.dart';
import 'package:hostations_commerce/features/address/data/model/address.dart';
import 'package:hostations_commerce/widgets/app_widgets.dart';
import '../cubits/address_cubit.dart';
import '../cubits/address_state.dart';
import '../screens/address_form_screen.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({Key? key}) : super(key: key);

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  late AppCubit _appCubit;
  @override
  void initState() {
    _appCubit = context.read<AppCubit>();
    context.read<AddressCubit>().fetchAllAddresses(_appCubit.state.isGuest);
    super.initState();
  }

  void _navigateToForm({Address? address}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddressFormScreen(initialAddress: address),
      ),
    );
    // Refresh after add/edit only if changed
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Addresses')),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: BlocBuilder<AddressCubit, AddressState>(
        builder: (context, state) {
          if (state.status == AddressStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == AddressStatus.failure) {
            return Center(child: AppText('Error: ${state.error}', style: TextStyle(color: Colors.red)));
          } else if (state.addresses.isEmpty) {
            return const Center(child: AppText('No addresses found.'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              await context.read<AddressCubit>().fetchAllAddresses(_appCubit.state.isGuest);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.addresses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final address = state.addresses[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: AppText(address.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: AppText(address.address1),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _navigateToForm(address: address),
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            context.read<AddressCubit>().deleteAddress(address.id, _appCubit.state.isGuest);
                          },
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: AppButton(
        label: 'Add Address',
        icon: Icons.add,
        onPressed: () => _navigateToForm(),
      ),
    );
  }
}
