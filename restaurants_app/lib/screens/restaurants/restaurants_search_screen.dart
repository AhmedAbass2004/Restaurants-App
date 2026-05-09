import 'package:flutter/material.dart';

import '../../controllers/search_controller.dart' as search_ctrl;
import '../../models/product.dart';
import '../../widgets/error_message_widget.dart';
import 'restaurant_search_results_list_screen.dart';
import 'restaurant_search_results_map_screen.dart';

class RestaurantsSearchScreen extends StatefulWidget {
  const RestaurantsSearchScreen({super.key});

  @override
  State<RestaurantsSearchScreen> createState() =>
      _RestaurantsSearchScreenState();
}

class _RestaurantsSearchScreenState extends State<RestaurantsSearchScreen> {
  final search_ctrl.SearchController _controller =
      search_ctrl.SearchController();

  Product? _selectedProduct;
  bool _useMapView = false;

  @override
  void initState() {
    super.initState();
    _controller.loadProducts();
    // Load location in background (fire and forget to avoid blocking UI)
    _controller.loadCurrentLocation().ignore();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a product')));
      return;
    }

    await _controller.searchByProduct(_selectedProduct!.name);

    if (!mounted) return;

    // Navigate to results screen with toggle for list/map
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _useMapView
            ? RestaurantSearchResultsMapScreen(controller: _controller)
            : RestaurantSearchResultsListScreen(controller: _controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search by Product'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Error message
            StreamBuilder<String?>(
              stream: _controller.errorStream,
              builder: (_, snapshot) =>
                  ErrorMessageWidget(errorMessage: snapshot.data),
            ),
            const SizedBox(height: 20),

            // Product selection header
            Text(
              'Select a Product',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Product dropdown
            StreamBuilder<List<Product>>(
              stream: _controller.productsStream,
              initialData: const [],
              builder: (_, snapshot) {
                final products = snapshot.data ?? [];
                return DropdownButtonFormField<Product>(
                  value: _selectedProduct,
                  decoration: InputDecoration(
                    labelText: 'Choose a product',
                    prefixIcon: const Icon(Icons.fastfood_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: products
                      .map(
                        (product) => DropdownMenuItem<Product>(
                          value: product,
                          child: Text(product.name),
                        ),
                      )
                      .toList(),
                  onChanged: (product) {
                    setState(() => _selectedProduct = product);
                  },
                );
              },
            ),
            const SizedBox(height: 20),

            // View toggle
            Text(
              'View Results As',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: false,
                        label: Text('List View'),
                        icon: Icon(Icons.list),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text('Map View'),
                        icon: Icon(Icons.map),
                      ),
                    ],
                    selected: {_useMapView},
                    onSelectionChanged: (Set<bool> newSelection) {
                      setState(() => _useMapView = newSelection.first);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Search button
            SizedBox(
              height: 56,
              child: StreamBuilder<bool>(
                stream: _controller.loadingStream,
                initialData: false,
                builder: (_, snapshot) {
                  final isLoading = snapshot.data ?? false;
                  return ElevatedButton(
                    onPressed: isLoading ? null : _performSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Search',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Info card
            Container(
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border.all(color: Colors.blue[200]!),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Text(
                        'Tips',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Select a product to see all restaurants serving it\n'
                    '• View results as a list or on an interactive map\n'
                    '• Enable location services to see distances\n'
                    '• Tap any result to get directions',
                    style: TextStyle(color: Colors.blue[700], fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
