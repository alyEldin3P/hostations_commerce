import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hostations_commerce/core/di/dependency_injection.dart';
import 'package:hostations_commerce/features/cart/presentation/cubits/cart_cubit.dart';
import 'package:hostations_commerce/widgets/app_widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:developer';

class ConfirmOrderScreen extends StatefulWidget {
  static const routeName = '/confirm-order';
  final VoidCallback? onOrderSuccess;
  final VoidCallback? onOrderError;

  const ConfirmOrderScreen({Key? key, this.onOrderSuccess, this.onOrderError}) : super(key: key);

  @override
  State<ConfirmOrderScreen> createState() => _ConfirmOrderScreenState();
}

class _ConfirmOrderScreenState extends State<ConfirmOrderScreen> {
  bool _showWebView = false;
  String? _checkoutUrl;
  bool _loading = false;
  bool _error = false;
  // Make controller late initialized or nullable if not needed immediately
  late final WebViewController _webViewController;
  final TextEditingController _couponController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize only if needed, or move initialization to where it's first used.
    // Consider initializing it lazily inside _startCheckout if it's only used there.
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (nav) {
            log('[WebView] Navigation request: \n  url: ${nav.url} \n  isMainFrame: ${nav.isMainFrame}');
            // Make the thank you check more robust if possible (e.g., specific path segment)
            if (nav.url.contains('/thank_you')) {
              // Consider making this check more specific if needed
              log('[WebView] Thank you page detected, finishing checkout.');
              widget.onOrderSuccess?.call();
              // Ensure context is still valid if async operations happened before pop
              if (mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (url) {
            log('[WebView] Page started loading: $url');
            // Consider showing a loading indicator specific to the WebView here
          },
          onPageFinished: (url) {
            log('[WebView] Page finished loading: $url');
            // Consider hiding a loading indicator here
          },
          onWebResourceError: (error) {
// Log the error, potentially show a user\-friendly message or allow retry
            log('\[WebView\] Resource error\: code\=</span>{error.errorCode}, description=<span class="math-inline">\{error\.description\}, url\=</span>{error.url}');
            // Optionally revert to the summary view or show an error message overlay
            if (mounted) {
              setState(() {
                _error = true; // Or a specific webview error flag
                _showWebView = false; // Option: Go back to summary on error
                _loading = false;
              });
              widget.onOrderError?.call(); // Notify parent about the error
            }
          },
        ),
      );
  }

  Future<void> _startCheckout() async {
    // Prevent multiple simultaneous calls
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = false; // Reset error state
    });
    try {
      // It's generally safer to read the state *inside* the function
      // right before you use it, unless you specifically need the state
      // captured at the moment the button was pressed.
      final cartState = context.read<CartCubit>().state;

      // Ensure cart data is available
      if (cartState.cart.items.isEmpty) {
        log('[Checkout] Cart is empty, cannot proceed.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Your cart is empty.')),
          );
          setState(() {
            _loading = false;
          });
        }
        return;
      }

      // Validate selected payment method again (optional but good practice)
      if (cartState.selectedPaymentMethod == null) {
        log('[Checkout] No payment method selected.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a payment method.')),
          );
          setState(() {
            _loading = false;
          });
        }
        return;
      }

      final lineItems = cartState.cart.items
          .map((item) => {
                // Ensure the keys match exactly what your backend expects
                "variantId": item.variantId, // e.g., "gid://shopify/ProductVariant/12345"
                "quantity": item.quantity,
              })
          .toList();

      // Get other necessary data (ensure it's available)
      final notes = _notesController.text.trim();
      final coupon = _couponController.text.trim();

      // Assuming DependencyInjector().checkoutRepository exists and is correct
      final checkoutRepository = DependencyInjector().checkoutRepository;
      final checkout = await checkoutRepository.createCheckoutSession(lineItems: lineItems, email: 'TODO');

      log('[WebView] Loading checkout URL: \n  url: ${checkout.checkoutUrl}');

      // Check context validity before proceeding
      if (!mounted) return;

      // Load the URL in the WebView
      _webViewController.loadRequest(Uri.parse(checkout.checkoutUrl));

      setState(() {
        _checkoutUrl = checkout.checkoutUrl;
        _showWebView = true; // Show the WebView
        _loading = false; // Stop loading indicator for the button
      });
    } catch (e, stackTrace) {
      // Catch specific exceptions if possible
      log('[Checkout] Error creating checkout: $e\n$stackTrace');
      if (mounted) {
        setState(() {
          _error = true; // Show error message on the summary screen
          _loading = false;
        });
        // Show a user-friendly error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting checkout: ${e.toString()}')),
        );
      }
      widget.onOrderError?.call(); // Notify parent
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the state here to rebuild when cart changes
    final cartState = context.watch<CartCubit>().state;
    final selectedPaymentMethod = cartState.selectedPaymentMethod;

    // Define constants or retrieve from configuration
    const double shippingFee = 50.0;
    const String shippingLabel = 'Standard Shipping';

    // Safely parse subtotal, default to 0.0 if parsing fails or is null
    final double subtotal = double.tryParse(cartState.cart.subtotal ?? '0') ?? 0.0;
    final double total = subtotal + shippingFee; // Apply coupon discount here if applicable

    // Determine if the main button should be enabled
    final canProceed = selectedPaymentMethod != null && !_loading && cartState.cart.items.isNotEmpty;

    return AppScaffold(
      // Or replace with standard Scaffold for testing
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // Or endFloat etc.
      // Use standard AppBar for simplicity or your custom one
      appBar: AppBar(
        title: Text(_showWebView ? 'Complete Payment' : 'Confirm Order'),
        // Optionally hide back button when WebView is shown
        // automaticallyImplyLeading: !_showWebView,
      ),
      // Use a Builder to get a context below the Scaffold if needed for Snackbars immediately
      body: Builder(builder: (scaffoldContext) {
        // Use scaffoldContext for Snackbars if needed
        if (_showWebView && _checkoutUrl != null) {
          // Optionally show a loading indicator on top of the WebView while it loads initially
          return Stack(children: [
            WebViewWidget(controller: _webViewController),
            // Add a loading indicator here if desired while page loads
            // if (_isWebViewLoading) Center(child: CircularProgressIndicator()),
          ]);
        } else {
          // Order Summary View
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0), // Consistent padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // Remove mainAxisSize: MainAxisSize.min
              // mainAxisSize: MainAxisSize.min, // REMOVED
              children: [
                // Section: Shipping Address
                Text('Shipping Address:', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                // Provide a clearer fallback text
                Text(cartState.cart.shippingAddress?.address1 ?? 'No shipping address provided.'), // Assuming a formattedAddress method
                const SizedBox(height: 24),

                // Section: Payment Method
                Text('Payment Method:', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Display selected method or prompt to select
                    Expanded(
                      // Allow text to wrap if long
                      child: Text(
                        selectedPaymentMethod ?? 'No payment method selected',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate back to the screen where payment is selected
                        Navigator.pop(context);
                      },
                      child: const Text('Change'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Section: Order Summary
                Text('Order Summary:', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                // Use ListView.builder if list can be very long, otherwise map is fine
                if (cartState.cart.items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: Text('Your cart is empty.')),
                  )
                else
                  Column(
                    // Keep items in a column
                    children: cartState.cart.items
                        .map((item) => ListTile(
                              title: Text(item.title),
                              subtitle: Text('Variant: ${item.variantTitle ?? '-'} \nQty: <span class="math-inline">\{item\.quantity\}</span>'), // Show variant title if available
                              trailing: Text('</span>{item.price} ${item.currency}'),
                              isThreeLine: item.variantTitle != null, // Adjust layout for variant title
                              dense: true,
                            ))
                        .toList(),
                  ),
                const SizedBox(height: 16),
                _buildSummaryRow('Subtotal', subtotal, cartState.cart.currency),
                _buildSummaryRow(shippingLabel, shippingFee, cartState.cart.currency),
                // Add Coupon discount row here if applicable
                const Divider(thickness: 1),
                _buildSummaryRow('Total', total, cartState.cart.currency, isTotal: true),
                const SizedBox(height: 24),

                // Section: Coupon and Notes
                TextField(
                  controller: _couponController,
                  decoration: InputDecoration(
                    labelText: 'Coupon Code (Optional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Order Notes (Optional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  maxLines: 3, // Allow multiple lines for notes
                ),
                const SizedBox(height: 24),

                // Section: Error Message
                if (_error)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'Failed to initiate checkout. Please check your connection and try again.',
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Section: Action Button
                Center(
                  // Center the button
                  child: AppButton(
                    // Use your custom button
                    label: _loading ? 'Processing...' : 'Confirm & Pay',
                    loading: _loading,
                    // Disable button if loading, no payment method, or cart empty
                    onPressed: canProceed ? _startCheckout : null,
                    // Make button wider (optional)
                    // minWidth: double.infinity,
                  ),
                ),
                const SizedBox(height: 24), // Add padding at the bottom
              ],
            ),
          );
        }
      }),
    );
  }

  // Helper to build summary rows consistently, including currency
  Widget _buildSummaryRow(String label, double amount, String currencyCode, {bool isTotal = false}) {
    final style = isTotal ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold) : Theme.of(context).textTheme.bodyLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('$currencyCode ${amount.toStringAsFixed(2)}', style: style),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _couponController.dispose();
    _notesController.dispose();
    // If WebViewController is not needed after dispose, you might not need to do anything,
    // but check its documentation if specific cleanup is required.
    super.dispose();
  }
}
