import 'package:flutter/material.dart';

class OrderStatusScreen extends StatelessWidget {
  final bool success;
  final String? error;
  const OrderStatusScreen({Key? key, this.success = true, this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Status')),
      body: Center(
        child: success
            ? const Icon(Icons.check_circle, color: Colors.green, size: 80)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 80),
                  const SizedBox(height: 16),
                  Text(error ?? 'Order Failed'),
                ],
              ),
      ),
    );
  }
}
