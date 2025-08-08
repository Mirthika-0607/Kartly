import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/product_model.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';

class WishlistScreen extends StatefulWidget {
  final String phoneNumber;
  final Function(Product) onProductSelected;
  final String searchQuery;

  const WishlistScreen({
    Key? key,
    required this.phoneNumber,
    required this.onProductSelected,
    this.searchQuery = '',
  }) : super(key: key);

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  List<Product> _wishlistProducts = [];
  String? _errorMessage;
  late TabController _tabController;
  Map<String, bool> _wishlistStatus = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchWishlistProducts();
  }

  @override
  void didUpdateWidget(WishlistScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _fetchWishlistProducts(); // Re-fetch or filter wishlist when search query changes
    }
  }

  Future<void> _fetchWishlistProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final wishlist = await ApiService().fetchWishlist(context);
      final products = await ApiService().fetchProducts(context);
      if (mounted) {
        setState(() {
          _wishlistProducts = products.where((product) {
            final matchesWishlist = wishlist.any((item) => item['productId'] == product.productId);
            final matchesSearch = widget.searchQuery.isEmpty ||
                (product.productName?.toLowerCase().contains(widget.searchQuery.toLowerCase()) ?? false);
            return matchesWishlist && matchesSearch;
          }).toList();
          _wishlistStatus = {for (var product in _wishlistProducts) product.productId ?? '': true};
          _isLoading = false;
        });
        debugPrint('Fetched wishlist products: ${_wishlistProducts.map((p) => p.toJson()).toList()}');
        debugPrint('Wishlist Dresses: ${getFilteredProducts('Dresses').length}');
        debugPrint('Wishlist Sandals: ${getFilteredProducts('Sandals').length}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load wishlist: $e';
        });
      }
    }
  }

  Future<void> _toggleWishlist(String productId) async {
    if (productId.isEmpty) {
      ApiService.showError(context, 'Invalid product ID');
      return;
    }
    final isInWishlist = _wishlistStatus[productId] ?? false;
    try {
      if (isInWishlist) {
        await ApiService().removeFromWishlist(context, productId);
        if (mounted) {
          setState(() {
            _wishlistStatus[productId] = false;
            _wishlistProducts.removeWhere((product) => product.productId == productId);
          });
          ApiService.showSuccess(context, 'Removed from wishlist');
        }
      } else {
        await ApiService().addToWishlist(context, productId);
        if (mounted) {
          setState(() {
            _wishlistStatus[productId] = true;
          });
          ApiService.showSuccess(context, 'Added to wishlist');
        }
      }
    } catch (e) {
      if (mounted) {
        ApiService.showError(context, 'Wishlist operation failed: $e');
      }
    }
  }

  List<Product> getFilteredProducts(String category) {
    return _wishlistProducts
        .where((product) =>
    product.productCategory != null &&
        product.productCategory!.toLowerCase() == category.toLowerCase())
        .toList();
  }

  bool _isBase64Image(String? imagePath) {
    return imagePath != null && imagePath.startsWith('data:image/');
  }

  String _extractBase64Data(String dataUrl) {
    final parts = dataUrl.split(',');
    return parts.length > 1 ? parts[1] : '';
  }

  Widget _buildProductImage(Product product) {
    if (product.productImage == null) {
      return Icon(Icons.image_not_supported, color: AppColors.teal);
    }

    if (_isBase64Image(product.productImage)) {
      try {
        final base64Data = _extractBase64Data(product.productImage!);
        final imageBytes = base64Decode(base64Data);

        return ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.memory(
            imageBytes,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Base64 image decode error: $error');
              return Icon(Icons.image_not_supported, color: AppColors.teal);
            },
          ),
        );
      } catch (e) {
        debugPrint('Error decoding base64 image: $e');
        return Icon(Icons.image_not_supported, color: AppColors.teal);
      }
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          product.productImage!,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Network image load error for ${product.productImage}: $error');
            return Icon(Icons.image_not_supported, color: AppColors.teal);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: 60,
              height: 60,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.darkBlue,
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator(color: AppColors.darkBlue))
        : _errorMessage != null
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _errorMessage!,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.teal,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchWishlistProducts,
            style: AppColors.primaryButtonStyle(),
            child: Text(
              'Retry',
              style: TextStyle(color: AppColors.beige),
            ),
          ),
        ],
      ),
    )
        : Column(
      children: [
        TabBar(
          controller: _tabController,
          indicatorColor: AppColors.darkBlue,
          labelColor: AppColors.darkBlue,
          unselectedLabelColor: AppColors.teal,
          tabs: const [
            Tab(text: 'Dresses'),
            Tab(text: 'Sandals'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildProductList(getFilteredProducts('Dresses')),
              _buildProductList(getFilteredProducts('Sandals')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductList(List<Product> products) {
    if (products.isEmpty) {
      return Center(
        child: Text(
          widget.searchQuery.isEmpty
              ? 'No products in your wishlist'
              : 'No products match your search',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.teal,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          color: AppColors.beige,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Stack(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(16.0),
                title: Text(
                  product.productName ?? 'Unnamed Product',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    if (product.productDescription != null)
                      Text(
                        product.productDescription!,
                        style: TextStyle(
                          color: AppColors.teal,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    if (product.productPrice != null)
                      Text(
                        '${product.productPrice!}',
                        style: TextStyle(
                          color: AppColors.darkBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    const SizedBox(height: 4),
                    if (product.productCategory != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.darkBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product.productCategory!.toUpperCase(),
                          style: TextStyle(
                            color: AppColors.darkBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                leading: _buildProductImage(product),
                onTap: () => widget.onProductSelected(product),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: IconButton(
                  icon: Icon(
                    _wishlistStatus[product.productId] ?? false
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: () => _toggleWishlist(product.productId ?? ''),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}