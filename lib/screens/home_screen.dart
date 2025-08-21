import 'package:flutter/material.dart';
import 'package:shopping_mart/screens/product_detail_screen.dart';
import 'package:shopping_mart/screens/product_list_body.dart';
import 'package:shopping_mart/screens/wishlist_body.dart';
import 'package:shopping_mart/screens/user_account_body.dart';
import 'package:shopping_mart/models/product_model.dart';
import '../utils/theme.dart';
import './order_list_screen.dart';
import './order_detail_screen.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  final String phoneNumber;
  const HomeScreen({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  List<dynamic>? _cartData; // <-- store cart data here
  bool _isLoadingCart = false;

  // titles
  final List<String> _titles = ['Shopping', 'Wishlist', 'Account'];

  // product selection callback
  void _onProductSelected(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetail(product: product),
      ),
    ).then((_) {
      _loadCart(); // refresh cart when coming back
    });
  }

  // screens
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      ProductList(
        phoneNumber: widget.phoneNumber,
        onProductSelected: _onProductSelected,
        searchQuery: _searchQuery,
      ),
      WishlistScreen(
        phoneNumber: widget.phoneNumber,
        onProductSelected: _onProductSelected,
        searchQuery: _searchQuery,
      ),
      AccountScreen(phoneNumber: widget.phoneNumber),
    ];
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        _screens[0] = ProductList(
          phoneNumber: widget.phoneNumber,
          onProductSelected: _onProductSelected,
          searchQuery: _searchQuery,
        );
        _screens[1] = WishlistScreen(
          phoneNumber: widget.phoneNumber,
          onProductSelected: _onProductSelected,
          searchQuery: _searchQuery,
        );
      });
    });

    _loadCart(); // load cart when screen starts
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoadingCart = true;
    });
    final cartData = await ApiService().getCartList(context);
    if (mounted) {
      setState(() {
        _cartData = cartData;
        _isLoadingCart = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _searchController.clear();
      _isSearching = false;
    });
    _loadCart(); // refresh cart whenever tab changes
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
      }
    });
  }

  void _navigateToOrderList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderListScreen(phoneNumber: widget.phoneNumber),
      ),
    );
  }

  Future<void> _showCartBottomSheet() async {
    await _loadCart(); // refresh before showing
    if (_cartData == null ||
        _cartData!.isEmpty ||
        _cartData![0]['items'].isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cart is empty')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CartBottomSheet(cartData: _cartData!),
    ).then((_) {
      _loadCart(); // refresh after bottom sheet closes
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasCartItems = _cartData != null &&
        _cartData!.isNotEmpty &&
        _cartData![0]['items'].isNotEmpty;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: _isSearching && _selectedIndex != 2
            ? TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search products...',
            hintStyle: TextStyle(color: AppColors.teal),
            border: InputBorder.none,
          ),
          style: TextStyle(color: AppColors.beige),
          autofocus: true,
        )
            : Text(
          _titles[_selectedIndex],
          style: AppColors.primaryTextStyle()
              .copyWith(color: AppColors.beige),
        ),
        backgroundColor: AppColors.darkBlue,
        automaticallyImplyLeading: false,
        actions: [
          if (_selectedIndex != 2)
            IconButton(
              icon: Icon(
                  _isSearching ? Icons.close : Icons.search,
                  color: AppColors.beige),
              onPressed: _toggleSearch,
            ),
          IconButton(
            icon: Icon(Icons.receipt_long, color: AppColors.beige),
            onPressed: _navigateToOrderList,
          ),
        ],
      ),
      body: Stack(
        children: [
          _screens[_selectedIndex],
          if (_selectedIndex == 0 && hasCartItems) // ✅ only visible if cart has items
            Positioned(
              left: 0,
              right: 0,
              bottom: 56,
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
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shopping'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Wishlist'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: 'Account'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.darkBlue,
        unselectedItemColor: AppColors.teal,
        onTap: _onItemTapped,
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
        // Check if cart is empty after removal
        if (updatedCart.isEmpty || updatedCart[0]['items'].isEmpty) {
          Navigator.pop(context); // Close the bottom sheet
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cart is empty'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Item removed from cart'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
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
      // Show SnackBar to confirm cart cleared
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
        Navigator.pop(context); // Close bottom sheet
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(
                orderId: order['orderId'], phoneNumber: phoneNumber),
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
    final cart = widget.cartData[0];
    final String? cartId = cart['cartId'];
    // Safely parse totalPrice
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