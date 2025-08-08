import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';


class ProductDetail extends StatelessWidget {
  final Product? product;


  const ProductDetail({Key? key, required this.product}) : super(key: key);


  // Function to show the Add to Cart dialog
  Future<void> _showAddToCartDialog(BuildContext context) async {
    if (product == null || product!.productId == null) {
      ApiService.showError(context, 'No product selected');
      return;
    }


    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');


    if (token == null) {
      ApiService.showError(context, 'No token found. Please log in again.');
      Navigator.pushReplacementNamed(context, '/generate');
      return;
    }


    // Create cart with default quantity of 1
    String? cartId;
    double totalPrice = 0.0;
    final createResponse = await ApiService().createCart(context, product!.productId!);
    if (createResponse != null) {
      cartId = createResponse['cartId'];
      totalPrice = (createResponse['totalPrice'] ?? 0.0).toDouble();
    } else {
      return;
    }


    // Show dialog with quantity controls and total amount
    if (context.mounted && cartId != null) {
      int quantity = 1;
      await showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product!.productName ?? 'Unnamed Product',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBlue,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await ApiService().deleteCart(dialogContext, cartId!);
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                      },
                      icon: Icon(Icons.close, color: AppColors.teal),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price: ${product!.productPrice!}',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total: \$${totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () async {
                            if (quantity > 1) {
                              setState(() {
                                quantity--;
                              });
                              final newTotal = await ApiService().updateCart(dialogContext, cartId!, product!.productId!, quantity);
                              if (newTotal != null) {
                                setState(() {
                                  totalPrice = newTotal;
                                });
                              }
                            }
                          },
                          icon: Icon(Icons.remove, color: AppColors.darkBlue),
                        ),
                        Text(
                          '$quantity',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              quantity++;
                            });
                            final newTotal = await ApiService().updateCart(dialogContext, cartId!, product!.productId!, quantity);
                            if (newTotal != null) {
                              setState(() {
                                totalPrice = newTotal;
                              });
                            }
                          },
                          icon: Icon(Icons.add, color: AppColors.darkBlue),
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    style: AppColors.primaryButtonStyle(),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        color: AppColors.beige,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    if (product == null) {
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product!.productImage != null)
                Container(
                  width: double.infinity,
                  child: Image.network(
                    product!.productImage!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('Image load error for ${product!.productImage}: $error');
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
                product!.productName ?? 'Unnamed Product',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
              const SizedBox(height: 8),
              if (product!.productDescription != null)
                Text(
                  product!.productDescription!,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.teal,
                  ),
                ),
              const SizedBox(height: 8),
              if (product!.productPrice != null)
                Text(
                  'Price: ${product!.productPrice!}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),
              const SizedBox(height: 8),
              if (product!.productCategory != null)
                Text(
                  'Category: ${product!.productCategory}',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.teal,
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showAddToCartDialog(context),
                style: AppColors.primaryButtonStyle(),
                child: Text(
                  'Add to Cart',
                  style: TextStyle(
                    color: AppColors.beige,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

