import 'package:flutter/material.dart';
import 'package:shopping_mart/screens/product_detail_screen.dart';
import 'package:shopping_mart/screens/product_list_body.dart';
import 'package:shopping_mart/screens/wishlist_body.dart';
import 'package:shopping_mart/screens/user_account_body.dart';
import 'package:shopping_mart/models/product_model.dart';
import '../utils/theme.dart';


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


  // List of titles for each screen
  final List<String> _titles = ['Shopping', 'Wishlist', 'Account'];


  // Callback for product selection to navigate to ProductDetail
  void _onProductSelected(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetail(product: product),
      ),
    );
  }


  // List of screens for BottomNavigationBar
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
        // Rebuild screens with updated search query
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
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Clear search when switching screens
      _searchController.clear();
      _isSearching = false;
    });
  }


  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          style: AppColors.primaryTextStyle().copyWith(color: AppColors.beige),
        ),
        backgroundColor: AppColors.darkBlue,
        automaticallyImplyLeading: false,
        actions: _selectedIndex != 2
            ? [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: AppColors.beige),
            onPressed: _toggleSearch,
          ),
        ]
            : [],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Shopping',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.darkBlue,
        unselectedItemColor: AppColors.teal,
        onTap: _onItemTapped,
      ),
    );
  }
}

