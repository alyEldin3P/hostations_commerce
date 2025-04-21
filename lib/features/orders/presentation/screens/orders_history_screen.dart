import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/orders_cubit.dart';
import '../cubits/orders_state.dart';

class OrdersHistoryScreen extends StatefulWidget {
  const OrdersHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrdersHistoryScreen> createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends State<OrdersHistoryScreen> {
  late OrdersCubit _cubit;
  @override
  void initState() {
    super.initState();
    _cubit = context.read<OrdersCubit>();
    _cubit.fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders History')),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          if (state.status == OrdersStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == OrdersStatus.failure) {
            return Center(child: Text(state.error ?? 'Failed to load orders'));
          } else if (state.status == OrdersStatus.loaded && state.orders.isNotEmpty) {
            return ListView.builder(
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return ListTile(
                  title: Text(order.name),
                  subtitle: Text('Total: ${order.total} ${order.currencyCode}\nStatus: ${order.fulfillmentStatus}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // TODO: Navigate to order details screen
                  },
                );
              },
            );
          } else {
            return const Center(child: Text('No orders found.'));
          }
        },
      ),
    );
  }
}
