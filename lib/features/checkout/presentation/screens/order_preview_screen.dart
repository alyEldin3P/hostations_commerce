import 'package:flutter/material.dart';
import 'payment_method_screen.dart';

class OrderPreviewScreen extends StatelessWidget {
  const OrderPreviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Remove hardcoded shipping when real shipping methods are enabled
    const double shippingFee = 50.0;
    const String shippingLabel = 'Standard Shipping';
    // You may want to fetch cart totals from your CartCubit/Bloc here
    final double subtotal = 0; // TODO: Replace with real subtotal
    final double total = subtotal + shippingFee;
    return Scaffold(
      appBar: AppBar(title: const Text('Order Preview')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Order summary preview
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Order Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 12),
                    _buildSummaryRow('Subtotal', subtotal),
                    _buildSummaryRow(shippingLabel, shippingFee),
                    const Divider(),
                    _buildSummaryRow('Total', total, isTotal: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Coupon Code'),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(labelText: 'Order Notes'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PaymentMethodScreen()),
                );
              },
              child: const Text('Next: Payment Method'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: isTotal ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16) : null),
          Text('EGP ${amount.toStringAsFixed(2)}', style: isTotal ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16) : null),
        ],
      ),
    );
  }
}
