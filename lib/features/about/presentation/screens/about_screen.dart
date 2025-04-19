import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  static const String routeName = '/about';

  final String type;

  const AboutScreen({
    Key? key,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getContent(),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                if (type == 'about')
                  Column(
                    children: [
                      const Divider(),
                      const SizedBox(height: 16),
                      const Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          // TODO: Open terms of service
                        },
                        child: const Text('Terms of Service'),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Open privacy policy
                        },
                        child: const Text('Privacy Policy'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    switch (type) {
      case 'privacy':
        return 'Privacy Policy';
      case 'terms':
        return 'Terms & Conditions';
      case 'about':
        return 'About Us';
      default:
        return 'About';
    }
  }

  String _getContent() {
    switch (type) {
      case 'privacy':
        return '''
        This privacy policy governs your use of the software application Hostations Commerce ("Application") for mobile devices that was created by Hostations.

        Privacy Policy
        The Application does not collect any personal information from its users.

        Support
        If you have any questions regarding privacy while using the Application, or have questions about our practices, please contact us via email at support@hostations.com.
        ''';

      case 'terms':
        return '''
        Terms and Conditions

        Welcome to Hostations Commerce!

        These terms and conditions outline the rules and regulations for the use of Hostations Commerce's Mobile Application.

        By accessing or using the Application, you agree to be bound by these Terms and Conditions. If you disagree with any part of these terms, please do not use our Application.

        Intellectual Property
        The Application and its original content, features, and functionality are owned by Hostations Commerce and are protected by international copyright, trademark, patent, trade secret, and other intellectual property or proprietary rights laws.

        Changes to Terms
        We reserve the right to modify these terms at any time. It is your responsibility to check this page periodically for changes. Your continued use of the Application following the posting of changes to these terms constitutes acceptance of those changes.
        ''';

      case 'about':
        return '''
        About Hostations Commerce

        Hostations Commerce is a powerful e-commerce mobile application that allows you to browse, purchase, and manage your shopping experience seamlessly.

        Features:
        - Browse products from various categories
        - Add items to your cart
        - Manage your wishlist
        - Track your orders
        - Receive notifications about special offers
        - Secure payment processing

        Contact Us
        If you have any questions or need assistance, please contact our support team at support@hostations.com.
        ''';

      default:
        return '';
    }
  }
}
