import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';
import './user_payment_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  final String phoneNumber;

  const OrderDetailScreen({Key? key, required this.orderId, required this.phoneNumber}) : super(key: key);

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Map<String, dynamic>? orderData;
  bool isLoading = true;
  final Map<String, TextEditingController> _reviewControllers = {};
  final Map<String, int?> _ratingControllers = {};

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final orders = await ApiService().getOrders(context, widget.phoneNumber);
      if (orders != null) {
        final order = orders.firstWhere(
              (o) => o['orderId'] == widget.orderId,
          orElse: () => {},
        );
        if (order.isNotEmpty && mounted) {
          setState(() {
            orderData = order;
            // Initialize review and rating controllers for each item
            for (var item in order['items'] ?? []) {
              final productId = item['productId'].toString();
              _reviewControllers[productId] = TextEditingController();
              _ratingControllers[productId] = null;
            }
            isLoading = false;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Order not found')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch order: $e')),
      );
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _updateQuantity(String productId, String action) async {
    setState(() {
      isLoading = true;
    });

    try {
      await ApiService().addOrUpdateOrder(
        context,
        phoneNumber: widget.phoneNumber,
        orderId: widget.orderId,
        productId: productId,
        action: action,
      );
      await _fetchOrderDetails();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order updated'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update order: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _removeItem(String productId) async {
    setState(() {
      isLoading = true;
    });

    try {
      await ApiService().addOrUpdateOrder(
        context,
        phoneNumber: widget.phoneNumber,
        orderId: widget.orderId,
        productId: productId,
        action: 'remove',
      );
      await _fetchOrderDetails();
      if (orderData == null || orderData!['items'].isEmpty) {
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item removed from order'),
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
          isLoading = false;
        });
      }
    }
  }

  Future<void> _cancelOrder() async {
    setState(() {
      isLoading = true;
    });

    try {
      await ApiService().deleteOrder(context, widget.phoneNumber, widget.orderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order cancelled'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel order: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _makePayment() async {
    if (orderData!['paymentDetail']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment already completed'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          orderId: widget.orderId,
          phoneNumber: widget.phoneNumber,
          totalPrice: double.tryParse(orderData!['totalPrice']?.toString().replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
        ),
      ),
    );
  }

  Future<void> _submitReview(String productId) async {
    final reviewText = _reviewControllers[productId]!.text.trim();
    final rating = _ratingControllers[productId];

    if (reviewText.isEmpty || rating == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please provide both a rating and a review'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await ApiService().createReview(
        context,
        productId: productId,
        userRating: rating,
        userReview: reviewText,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Review submitted successfully'),
          duration: Duration(seconds: 2),
        ),
      );
      // Clear review input
      _reviewControllers[productId]!.clear();
      _ratingControllers[productId] = null;
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit review: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildStarRatingInput(String productId) {
    return Row(
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return IconButton(
          icon: Icon(
            _ratingControllers[productId] != null && _ratingControllers[productId]! >= starValue
                ? Icons.star
                : Icons.star_border,
            color: AppColors.darkBlue,
            size: 24,
          ),
          onPressed: isLoading
              ? null
              : () {
            setState(() {
              _ratingControllers[productId] = starValue;
            });
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Order Details', style: TextStyle(color: AppColors.beige)),
          backgroundColor: AppColors.darkBlue,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.beige),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(child: CircularProgressIndicator(color: AppColors.darkBlue)),
      );
    }

    if (orderData == null || orderData!['items'].isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Order Details', style: TextStyle(color: AppColors.beige)),
          backgroundColor: AppColors.darkBlue,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.beige),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Text(
            'Order is empty or not found',
            style: TextStyle(fontSize: 18, color: AppColors.teal),
          ),
        ),
      );
    }

    final items = orderData!['items'] as List<dynamic>;
    String totalPriceStr = orderData!['totalPrice']?.toString() ?? '0';
    totalPriceStr = totalPriceStr.replaceAll(RegExp(r'[^\d.-]'), '');
    final double totalPrice = double.tryParse(totalPriceStr) ?? 0.0;
    final bool isDelivered = orderData!['orderdelivered'] == true;
    final bool isPaid = orderData!['paymentDetail'] == true;
    final bool canReview = isDelivered && orderData!['orderplaced'] == true;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details', style: TextStyle(color: AppColors.beige)),
        backgroundColor: AppColors.darkBlue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.beige),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: ${orderData!['orderId']}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBlue,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Status: ${orderData!['orderplaced'] ? 'Placed' : 'Not Placed'}',
              style: TextStyle(fontSize: 16, color: AppColors.teal),
            ),
            Text(
              'Delivery: ${orderData!['orderdelivered'] ? 'Delivered' : 'Pending'}',
              style: TextStyle(fontSize: 16, color: AppColors.teal),
            ),
            Text(
              'Payment: ${orderData!['paymentDetail'] ? 'Paid' : 'Pending'}',
              style: TextStyle(fontSize: 16, color: AppColors.teal),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final String productId = item['productId'].toString();
                  final quantity = item['quantity'] ?? 0;
                  final String productName = item['productName'] ?? 'Unnamed Product';
                  String priceStr = item['productPrice']?.toString() ?? '0';
                  priceStr = priceStr.replaceAll(RegExp(r'[^\d.-]'), '');
                  final double price = double.tryParse(priceStr) ?? 0.0;
                  final double subtotal = price * quantity;

                  return Card(
                    color: AppColors.beige,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(
                              productName,
                              style: TextStyle(color: AppColors.darkBlue),
                            ),
                            subtitle: Text(
                              'Price: $price | Subtotal: $subtotal | Quantity: $quantity',
                              style: TextStyle(color: AppColors.teal),
                            ),
                            trailing: isDelivered || isPaid
                                ? null
                                : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove, color: AppColors.darkBlue),
                                  onPressed: isLoading
                                      ? null
                                      : () async {
                                    if (quantity <= 1) {
                                      await _removeItem(productId);
                                    } else {
                                      await _updateQuantity(productId, 'decrement');
                                    }
                                  },
                                ),
                                Text('$quantity', style: TextStyle(fontSize: 16)),
                                IconButton(
                                  icon: Icon(Icons.add, color: AppColors.darkBlue),
                                  onPressed: isLoading
                                      ? null
                                      : () => _updateQuantity(productId, 'increment'),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: AppColors.teal),
                                  onPressed: isLoading ? null : () => _removeItem(productId),
                                ),
                              ],
                            ),
                          ),
                          if (canReview) ...[
                            Divider(),
                            Text(
                              'Rate this product:',
                              style: TextStyle(color: AppColors.darkBlue, fontSize: 16),
                            ),
                            _buildStarRatingInput(productId),
                            TextField(
                              controller: _reviewControllers[productId],
                              decoration: InputDecoration(
                                hintText: 'Write your review...',
                                hintStyle: TextStyle(color: AppColors.teal),
                                border: OutlineInputBorder(),
                              ),
                              style: TextStyle(color: AppColors.darkBlue),
                              maxLines: 3,
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: isLoading ? null : () => _submitReview(productId),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkBlue,
                                foregroundColor: AppColors.beige,
                              ),
                              child: Text('Submit Review'),
                            ),
                          ],
                        ],
                      ),
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
            if (!isDelivered)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: isLoading ? null : _cancelOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: AppColors.beige,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(color: AppColors.beige)
                        : Text(
                      'Cancel Order',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: isLoading || orderData!['paymentDetail'] ? null : _makePayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkBlue,
                      foregroundColor: AppColors.beige,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(color: AppColors.beige)
                        : Text(
                      'Make Payment',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _reviewControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }
}