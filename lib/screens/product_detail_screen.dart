  import 'package:flutter/material.dart';
  import '../models/product_model.dart';
  import '../services/api_service.dart';
  import '../utils/theme.dart';
  import './order_detail_screen.dart';

  class ProductDetail extends StatefulWidget {
    final Product? product;

    const ProductDetail({Key? key, required this.product}) : super(key: key);

    @override
    _ProductDetailState createState() => _ProductDetailState();
  }

  class _ProductDetailState extends State<ProductDetail> {
    double? averageRating;
    List<dynamic> reviews = [];
    bool isLoading = false;
    bool isLoadingReviews = false;

    // cart state for dynamic View Cart
    List<dynamic>? _cartData;
    bool _isLoadingCart = false;

    @override
    void initState() {
      super.initState();
      _fetchAverageRating();
      _fetchProductReviews();
      _loadCart(); // load cart to decide if View Cart should show
    }

    // === ADDED BACK: fetch avg rating ===
    Future<void> _fetchAverageRating() async {
      if (widget.product == null || widget.product!.productId == null) return;
      if (mounted) {
        setState(() {
          // using productRating directly since getavgrating route was removed
          averageRating = widget.product!.productRating?.toDouble() ?? 0.0;
        });
      }
    }

    // === ADDED BACK: fetch product reviews ===
    Future<void> _fetchProductReviews() async {
      if (widget.product == null || widget.product!.productId == null) return;
      setState(() => isLoadingReviews = true);
      try {
        final result = await ApiService()
            .fetchProductReviews(context, widget.product!.productId!);
        if (mounted) {
          setState(() {
            reviews = result ?? [];
            isLoadingReviews = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => isLoadingReviews = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load reviews: $e')),
          );
        }
      }
    }

    // === keeps your star rendering ===
    Widget _buildStarRating() {
      if (averageRating == null || averageRating == 0.0) {
        return Text('No ratings yet',
            style: TextStyle(fontSize: 16, color: AppColors.teal));
      }
      return Row(
        children: List.generate(5, (index) {
          final starValue = index + 1;
          IconData icon;
          if (averageRating! >= starValue) {
            icon = Icons.star;
          } else if (averageRating! >= starValue - 0.5) {
            icon = Icons.star_half;
          } else {
            icon = Icons.star_border;
          }
          return Icon(icon, color: AppColors.darkBlue, size: 20);
        }),
      );
    }

    // === ADDED BACK: build reviews section ===
    Widget _buildReviewsSection() {
      if (isLoadingReviews) {
        return Center(child: CircularProgressIndicator(color: AppColors.darkBlue));
      }
      if (reviews.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text('No reviews yet',
              style: TextStyle(fontSize: 16, color: AppColors.teal)),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reviews',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              final userName = review['user']?['name'] ?? 'Anonymous';
              final userReview = review['userReview'] ?? '';
              final userRating = (review['userRating']?.toDouble() ?? 0.0);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkBlue)),
                          Text(userReview,
                              style: TextStyle(fontSize: 14, color: AppColors.teal)),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: List.generate(5, (i) {
                          final starValue = i + 1;
                          IconData icon;
                          if (userRating >= starValue) {
                            icon = Icons.star;
                          } else if (userRating >= starValue - 0.5) {
                            icon = Icons.star_half;
                          } else {
                            icon = Icons.star_border;
                          }
                          return Icon(icon, color: AppColors.darkBlue, size: 16);
                        }),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      );
    }

    // === cart helpers for dynamic View Cart ===
    Future<void> _loadCart() async {
      setState(() => _isLoadingCart = true);
      final cartData = await ApiService().getCartList(context);
      if (mounted) {
        setState(() {
          _cartData = cartData;
          _isLoadingCart = false;
        });
      }
    }

    Future<void> _addToCart() async {
      if (widget.product == null || widget.product!.productId == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('No product selected')));
        return;
      }
      setState(() => isLoading = true);
      try {
        await ApiService().addOrUpdateCart(
          context,
          widget.product!.productId!,
          'increment', // or null if your API expects null → but 'increment' is typical
        );
        if (mounted) {
          await _loadCart(); // refresh cart so the button appears immediately
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.product!.productName} added to cart')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to add to cart: $e')));
      } finally {
        if (mounted) setState(() => isLoading = false);
      }
    }

    Future<void> _showCartBottomSheet() async {
      await _loadCart(); // refresh before showing
      if (_cartData == null ||
          _cartData!.isEmpty ||
          _cartData![0]['items'].isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Cart is empty')));
        return;
      }
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => CartBottomSheet(cartData: _cartData!),
      ).then((_) => _loadCart()); // refresh after closing
    }

    @override
    Widget build(BuildContext context) {
      if (widget.product == null) {
        return Center(
          child: Text('No product selected',
              style: TextStyle(fontSize: 16, color: AppColors.teal)),
        );
      }

      final bool hasCartItems = _cartData != null &&
          _cartData!.isNotEmpty &&
          _cartData![0]['items'].isNotEmpty;

      return Scaffold(
        extendBody: true,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.beige),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Product Details', style: TextStyle(color: AppColors.beige)),
          backgroundColor: AppColors.darkBlue,
        ),
        body: Stack(
          children: [
            // ---- your existing content (image/name/price/etc.) ----
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
                            debugPrint(
                                'Image load error for ${widget.product!.productImage}: $error');
                            return Center(
                              child: Icon(Icons.image_not_supported,
                                  color: AppColors.teal, size: 100),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.darkBlue, strokeWidth: 2),
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
                          color: AppColors.darkBlue),
                    ),
                    const SizedBox(height: 8),
                    if (widget.product!.productDescription != null)
                      Text(
                        widget.product!.productDescription!,
                        style:
                        TextStyle(fontSize: 16, color: AppColors.teal),
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
                                color: AppColors.darkBlue),
                          ),
                        _buildStarRating(),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (widget.product!.productCategory != null)
                      Text('Category: ${widget.product!.productCategory}',
                          style: TextStyle(fontSize: 16, color: AppColors.teal)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: isLoading ? null : _addToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkBlue,
                        foregroundColor: AppColors.beige,
                        padding:
                        EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: isLoading
                          ? CircularProgressIndicator(color: AppColors.beige)
                          : Text('Add to Cart', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 16),
                    _buildReviewsSection(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // ---- Dynamic View Cart button ----
            if (hasCartItems)
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
                      padding:
                      EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                    ),
                    child: Text('View Cart', style: TextStyle(fontSize: 16)),
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
        Navigator.pop(context);
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

    Future<void> _placeOrder() async {
      setState(() {
        _isLoading = true;
      });

      try {
        final phoneNumber = await ApiService().getUserPhoneNumber(context);
        if (phoneNumber == null) return;

        final order = await ApiService().addOrUpdateOrder(context, phoneNumber: phoneNumber);
        if (order != null && mounted) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailScreen(orderId: order['orderId'], phoneNumber: phoneNumber),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order placed successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $e'),
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
      String totalPriceStr = cart['totalPrice']?.toString() ?? '0';
      totalPriceStr = totalPriceStr.replaceAll(RegExp(r'[^\d.-]'), '');
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
                    final String productId = item['productId'].toString();
                    final quantity = item['quantity'] ?? 0;
                    final String productName = item['productName'] ?? 'Unnamed Product';
                    String priceStr = item['productPrice']?.toString() ?? '0';
                    priceStr = priceStr.replaceAll(RegExp(r'[^\d.-]'), '');
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
              ElevatedButton(
                onPressed: _isLoading ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBlue,
                  foregroundColor: AppColors.beige,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: AppColors.beige)
                    : Text(
                  'Place Order',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }