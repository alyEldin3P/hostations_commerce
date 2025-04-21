import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hostations_commerce/features/cart/presentation/cubits/cart_cubit.dart';
import 'package:hostations_commerce/features/cart/presentation/cubits/cart_state.dart';
import 'package:hostations_commerce/features/checkout/presentation/screens/confirm_order_screen.dart';
import 'package:hostations_commerce/widgets/app_widgets.dart';

class PaymentMethodScreen extends StatelessWidget {
  static const String routeName = '/payment-method';
  const PaymentMethodScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Select Payment Method')),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          final selected = state.selectedPaymentMethod;
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: ['Cash', 'Card', 'Online Payment'].length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final method = ['Cash', 'Card', 'Online Payment'][index];
              final isSelected = selected == method;
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => context.read<CartCubit>().selectPaymentMethod(method),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.08) : Theme.of(context).cardColor,
                    border: Border.all(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).iconTheme.color,
                      ),
                      const SizedBox(width: 18),
                      Expanded(child: Text(method)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            return AppButton(
              label: 'Continue',
              onPressed: state.selectedPaymentMethod == null
                  ? null
                  : () {
                      Navigator.of(context).pushNamed(ConfirmOrderScreen.routeName);
                    },
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
