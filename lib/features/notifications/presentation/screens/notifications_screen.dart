import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  static const String routeName = '/notifications';

  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              // TODO: Implement clear all notifications
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5, // TODO: Replace with actual notifications
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(
                  index % 2 == 0 ? Icons.shopping_cart : Icons.local_offer,
                  color: Colors.white,
                ),
              ),
              title: Text(
                index % 2 == 0
                    ? 'Your order has been shipped!'
                    : 'Special offer: 20% off on all products',
              ),
              subtitle: Text(
                '2 days ago',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              trailing: Icon(
                index % 2 == 0 ? Icons.check_circle : Icons.notifications,
                color: index % 2 == 0 ? Colors.green : Theme.of(context).primaryColor,
              ),
            ),
          );
        },
      ),
    );
  }
}
