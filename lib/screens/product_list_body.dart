import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/product_model.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';

class ProductList extends StatefulWidget {
  final String phoneNumber;
  final Function(Product) onProductSelected;
  final String searchQuery;

  const ProductList({
    Key? key,
    required this.phoneNumber,
    required this.onProductSelected,
    this.searchQuery = '',
  }) : super(key: key);

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  List<Product> _allProducts = [];
  List<Product> _products = [];
  String? _errorMessage;
  late TabController _tabController;
  Map<String, bool> _wishlistStatus = {};
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Map<String, dynamic>> _priceRanges = [
    {'min': 1000.0, 'max': 2000.0, 'label': '1000-2000'},
    {'min': 2000.0, 'max': 3000.0, 'label': '2000-3000'},
    {'min': 3000.0, 'max': 4000.0, 'label': '3000-4000'},
    {'min': 4000.0, 'max': 5000.0, 'label': '4000-5000'},
    {'min': 5000.0, 'max': 6000.0, 'label': '5000-6000'},
  ];
  List<String> _selectedPriceRanges = [];
  String? _selectedSortOption; // null, 'low_to_high', or 'high_to_low';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _fetchProducts();
  }

  @override
  void didUpdateWidget(ProductList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _applyFilters();
    }
  }

  void _handleTabSelection() {
    if (_tabController.index == 0 && mounted) {
      _scaffoldKey.currentState?.openDrawer();
      // Switch to Dresses tab to keep product list visible
      Future.delayed(Duration.zero, () {
        if (mounted) {
          _tabController.animateTo(1);
        }
      });
    }
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final products = await ApiService().fetchProducts(context);
      if (mounted) {
        setState(() {
          _allProducts = products;
          _applyFilters();
          _isLoading = false;
        });
        await _fetchWishlistStatus();
        debugPrint('Fetched products: ${_allProducts.map((p) => p.toJson()).toList()}');
        debugPrint('Filtered Dresses: ${getFilteredProducts('Dresses').length}');
        debugPrint('Filtered Sandals: ${getFilteredProducts('Sandals').length}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load products: $e';
        });
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _products = _allProducts.where((product) {
        final matchesSearch = widget.searchQuery.isEmpty ||
            (product.productName?.toLowerCase().contains(widget.searchQuery.toLowerCase()) ?? false);
        final price = double.tryParse((product.productPrice ?? '').replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
        final matchesPrice = _selectedPriceRanges.isEmpty ||
            _selectedPriceRanges.any((rangeLabel) {
              final range = _priceRanges.firstWhere((r) => r['label'] == rangeLabel);
              return price >= range['min'] && price <= range['max'];
            });
        return matchesSearch && matchesPrice;
      }).toList();
      // Apply sorting
      if (_selectedSortOption != null) {
        _products.sort((a, b) {
          final priceA = double.tryParse((a.productPrice ?? '').replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
          final priceB = double.tryParse((b.productPrice ?? '').replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
          return _selectedSortOption == 'low_to_high'
              ? priceA.compareTo(priceB)
              : priceB.compareTo(priceA);
        });
      }
    });
  }

  Future<void> _fetchWishlistStatus() async {
    final wishlist = await ApiService().fetchWishlist(context);
    if (mounted) {
      setState(() {
        _wishlistStatus = {
          for (var product in _allProducts)
            product.productId ?? '': wishlist.any((item) => item['productId'] == product.productId)
        };
      });
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

  List<Product> getFilteredProducts(String? category) {
    return _products.where((product) {
      final matchesCategory = category == null ||
          (product.productCategory != null &&
              product.productCategory!.toLowerCase() == category.toLowerCase());
      return matchesCategory;
    }).toList();
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
        return GestureDetector(
          onTap: () => widget.onProductSelected(product),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.memory(
              imageBytes,
              width: 120,
              height: 120,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Base64 image decode error: $error');
                return Icon(Icons.image_not_supported, color: AppColors.teal);
              },
            ),
          ),
        );
      } catch (e) {
        debugPrint('Error decoding base64 image: $e');
        return Icon(Icons.image_not_supported, color: AppColors.teal);
      }
    } else {
      return GestureDetector(
        onTap: () => widget.onProductSelected(product),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            product.productImage!,
            width: 120,
            height: 120,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Network image load error for ${product.productImage}: $error');
              return Icon(Icons.image_not_supported, color: AppColors.teal);
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return SizedBox(
                width: 120,
                height: 120,
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
        ),
      );
    }
  }

  Widget _buildFilterDrawer() {
    return Drawer(
      child: Container(
        color: AppColors.beige,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
              child: Text(
                'Filters',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ..._priceRanges.map((range) {
                    return CheckboxListTile(
                      title: Text(
                        range['label'],
                        style: TextStyle(color: AppColors.darkBlue),
                      ),
                      value: _selectedPriceRanges.contains(range['label']),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedPriceRanges.add(range['label']);
                          } else {
                            _selectedPriceRanges.remove(range['label']);
                          }
                        });
                      },
                      activeColor: AppColors.darkBlue,
                      checkColor: AppColors.beige,
                    );
                  }).toList(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.sort, color: AppColors.darkBlue),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: DropdownButton<String?>(
                            value: _selectedSortOption,
                            hint: Text('Sort', style: TextStyle(color: AppColors.darkBlue)),
                            isExpanded: true,
                            underline: Container(
                              height: 2,
                              color: AppColors.darkBlue,
                            ),
                            items: [
                              DropdownMenuItem<String?>(
                                value: null,
                                child: Text('None', style: TextStyle(color: AppColors.darkBlue)),
                              ),
                              DropdownMenuItem<String>(
                                value: 'low_to_high',
                                child: Text('Low to High', style: TextStyle(color: AppColors.darkBlue)),
                              ),
                              DropdownMenuItem<String>(
                                value: 'high_to_low',
                                child: Text('High to Low', style: TextStyle(color: AppColors.darkBlue)),
                              ),
                            ],
                            onChanged: (String? value) {
                              setState(() {
                                _selectedSortOption = value;
                                _applyFilters();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _applyFilters();
                      Navigator.pop(context);
                    },
                    style: AppColors.primaryButtonStyle(),
                    child: Text(
                      'Apply',
                      style: TextStyle(color: AppColors.beige),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedPriceRanges.clear();
                        _selectedSortOption = null;
                      });
                      _applyFilters();
                      Navigator.pop(context);
                    },
                    style: AppColors.primaryButtonStyle(),
                    child: Text(
                      'Clear',
                      style: TextStyle(color: AppColors.beige),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildFilterDrawer(),
      body: _isLoading
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
              onPressed: _fetchProducts,
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
              Tab(icon: Icon(Icons.filter_list)),
              Tab(text: 'Dresses'),
              Tab(text: 'Sandals'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductList(getFilteredProducts(null)), // Show all filtered products
                _buildProductList(getFilteredProducts('Dresses')),
                _buildProductList(getFilteredProducts('Sandals')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(List<Product> products) {
    if (products.isEmpty) {
      return Center(
        child: Text(
          _selectedPriceRanges.isEmpty && widget.searchQuery.isEmpty && _selectedSortOption == null
              ? (products == getFilteredProducts('Dresses')
              ? 'No Dresses available'
              : products == getFilteredProducts('Sandals')
              ? 'No Sandals available'
              : 'No products available')
              : 'No products match your filters',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.teal,
          ),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          color: AppColors.beige,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: _buildProductImage(product),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          product.productName ?? 'Unnamed Product',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkBlue,
                            fontSize: 16,
                          ),
                          maxLines: 1,
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
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 8,
                right: 8,
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
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }
}