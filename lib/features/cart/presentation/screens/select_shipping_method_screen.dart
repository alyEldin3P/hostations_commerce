import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/shipping_method.dart';
import '../cubits/shipping_method_cubit.dart';
import 'package:hostations_commerce/widgets/app_widgets.dart';

class SelectShippingMethodScreen extends StatefulWidget {
  final String cartId;
  const SelectShippingMethodScreen({Key? key, required this.cartId}) : super(key: key);

  @override
  State<SelectShippingMethodScreen> createState() => _SelectShippingMethodScreenState();
}

class _SelectShippingMethodScreenState extends State<SelectShippingMethodScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch shipping methods when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShippingMethodCubit>().fetchMethods(widget.cartId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const AppText('Select Shipping Method')),
      body: BlocBuilder<ShippingMethodCubit, ShippingMethodState>(
        builder: (context, state) {
          if (state.status == ShippingMethodStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == ShippingMethodStatus.failure) {
            return Center(child: AppText('Error: ${state.error}', style: const TextStyle(color: Colors.red)));
          } else if (state.methods.isEmpty) {
            return const Center(child: AppText('No shipping methods found.'));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: state.methods.length,
                  itemBuilder: (context, index) {
                    final method = state.methods[index];
                    return Card(
                      child: RadioListTile<ShippingMethod>(
                        value: method,
                        groupValue: state.selectedMethod,
                        onChanged: (m) => context.read<ShippingMethodCubit>().selectMethod(m!),
                        title: AppText(method.title),
                        subtitle: AppText(method.description),
                        secondary: AppText('${method.price.toStringAsFixed(2)} ${method.currency}'),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: AppButton(
                  label: 'Continue',
                  onPressed: state.selectedMethod == null
                      ? () {}
                      : () => Navigator.pop(context, state.selectedMethod),
                ),
              )
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
