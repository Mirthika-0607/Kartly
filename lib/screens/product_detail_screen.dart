import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';

class ProductDetail extends StatefulWidget {
  final Product? product;

  const ProductDetail({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  double? averageRating;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAverageRating();
  }

  Future<void> _fetchAverageRating() async {
    if (widget.product == null || widget.product!.productId == null) {
      return;
    }
    final result = await ApiService().fetchProductRating(context, widget.product!.productId!);
    if (result != null && mounted) {
      setState(() {
        averageRating = result['averageRating']?.toDouble() ?? 0.0;
      });
    }
  }

  Future<void> _addToCart() async {
    if (widget.product == null || widget.product!.productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No product selected')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await ApiService().addOrUpdateCart(
        context,
        widget.product!.productId!,
        null, // No action for "Add to Cart", increments by 1
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.product!.productName} added to cart')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to cart: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _showCartBottomSheet() async {
    final cartData = await ApiService().getCartList(context);

    // Show SnackBar and exit if cart is empty
    if (cartData == null || cartData.isEmpty || cartData[0]['items'].isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cart is empty'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Only show bottom sheet if cart has items
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CartBottomSheet(cartData: cartData),
    );
  }

  Widget _buildStarRating() {
    if (averageRating == null) {
      return Text(
        'No ratings yet',
        style: TextStyle(
          fontSize: 16,
          color: AppColors.teal,
        ),
      );
    }

    return Row(
      children: List.generate(5, (index) {
        double starValue = index + 1;
        IconData icon;
        if (averageRating! >= starValue) {
          icon = Icons.star;
        } else if (averageRating! >= starValue - 0.5) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }
        return Icon(
          icon,
          color: AppColors.darkBlue,
          size: 20,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.product == null) {
      return Center(
        child: Text(
          'No product selected',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.teal,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.beige),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Product Details',
          style: TextStyle(color: AppColors.beige),
        ),
        backgroundColor: AppColors.darkBlue,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.product!.productImage != null)
                    Container(
                      width: double.infinity,
                      child: Image.network(
                        widget.product!.productImage!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Image load error for ${widget.product!.productImage}: $error');
                          return Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: AppColors.teal,
                              size: 100,
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: AppColors.darkBlue,
                              strokeWidth: 2,
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    widget.product!.productName ?? 'Unnamed Product',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.product!.productDescription != null)
                    Text(
                      widget.product!.productDescription!,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.teal,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.product!.productPrice != null)
                        Text(
                          'Price: ${widget.product!.productPrice!}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkBlue,
                          ),
                        ),
                      _buildStarRating(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (widget.product!.productCategory != null)
                    Text(
                      'Category: ${widget.product!.productCategory}',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.teal,
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: isLoading ? null : _addToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkBlue,
                      foregroundColor: AppColors.beige,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(color: AppColors.beige)
                        : Text(
                      'Add to Cart',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 80), // Space to prevent overlap with fixed button
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.teal,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: ElevatedButton(
                onPressed: _showCartBottomSheet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppColors.beige,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  elevation: 0, // Remove shadow to merge with bottom
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                ),
                child: Text(
                  'View Cart',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CartBottomSheet extends StatefulWidget {
  final List<dynamic> cartData;

  const CartBottomSheet({Key? key, required this.cartData}) : super(key: key);

  @override
  _CartBottomSheetState createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends State<CartBottomSheet> {
  bool _isLoading = false;

  Future<void> _updateQuantity(String productId, String action) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService().addOrUpdateCart(context, productId, action);
      // Refresh cart data
      final updatedCart = await ApiService().getCartList(context);
      if (mounted && updatedCart != null) {
        setState(() {
          widget.cartData.clear();
          widget.cartData.addAll(updatedCart);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update cart: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeCartItem(String productId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService().removeCartItem(context, productId);
      // Refresh cart data
      final updatedCart = await ApiService().getCartList(context);
      if (mounted && updatedCart != null) {
        setState(() {
          widget.cartData.clear();
          widget.cartData.addAll(updatedCart);
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item removed from cart'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove item: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteCart(String cartId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService().deleteCart(context, cartId);
      // Close the bottom sheet
      Navigator.pop(context);
      // Refresh cart data
      final updatedCart = await ApiService().getCartList(context);
      if (mounted && updatedCart != null) {
        setState(() {
          widget.cartData.clear();
          widget.cartData.addAll(updatedCart);
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cart cleared'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to clear cart: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cartData.isEmpty || widget.cartData[0]['items'].isEmpty) {
      // This should not be reached due to check in _showCartBottomSheet
      return Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.teal,
            ),
          ),
        ),
      );
    }

    final cart = widget.cartData[0];
    final String? cartId = cart['cartId'];

    // Safely parse totalPrice (handles string, number, or null)
    String totalPriceStr = cart['totalPrice']?.toString() ?? '0';
    totalPriceStr = totalPriceStr.replaceAll(RegExp(r'[^\d.-]'), ''); // Strip non-numeric chars
    final double totalPrice = double.tryParse(totalPriceStr) ?? 0.0;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Cart',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),
                if (cartId != null)
                  TextButton(
                    onPressed: _isLoading ? null : () => _deleteCart(cartId),
                    child: Text(
                      'Clear Cart',
                      style: TextStyle(
                        color: AppColors.teal,
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: cart['items'].length,
                itemBuilder: (context, index) {
                  final item = cart['items'][index];
                  // Get the actual productId string from the item
                  final String productId = item['productId'].toString();
                  final quantity = item['quantity'] ?? 0;

                  // Get product details
                  final String productName = item['productName'] ?? 'Unnamed Product';

                  // Safely parse price (handles string, number, or null, with non-numeric stripping)
                  String priceStr = item['productPrice']?.toString() ?? '0';
                  priceStr = priceStr.replaceAll(RegExp(r'[^\d.-]'), ''); // Strip currency/symbols
                  final double price = double.tryParse(priceStr) ?? 0.0;

                  final double subtotal = price * quantity;

                  return ListTile(
                    title: Text(
                      productName,
                      style: TextStyle(color: AppColors.darkBlue),
                    ),
                    subtitle: Text(
                      'Price: $price | Subtotal: $subtotal',
                      style: TextStyle(color: AppColors.teal),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove, color: AppColors.darkBlue),
                          onPressed: _isLoading
                              ? null
                              : () async {
                            if (quantity <= 1) {
                              await _removeCartItem(productId);
                            } else {
                              await _updateQuantity(productId, 'decrement');
                            }
                          },
                        ),
                        Text('$quantity', style: TextStyle(fontSize: 16)),
                        IconButton(
                          icon: Icon(Icons.add, color: AppColors.darkBlue),
                          onPressed: _isLoading
                              ? null
                              : () => _updateQuantity(productId, 'increment'),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: AppColors.teal),
                          onPressed: _isLoading
                              ? null
                              : () => _removeCartItem(productId),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Total: $totalPrice',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}