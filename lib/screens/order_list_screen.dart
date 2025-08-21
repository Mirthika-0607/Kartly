import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';
import './order_detail_screen.dart';

class OrderListScreen extends StatefulWidget {
  final String phoneNumber;

  const OrderListScreen({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final orders = await ApiService().getOrders(context, widget.phoneNumber);
      if (mounted) {
        setState(() {
          // Filter orders to only include those with paymentDetail == true
          _orders = orders?.where((order) => order['paymentDetail'] == true).toList() ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load orders: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Orders',
          style: TextStyle(color: AppColors.beige),
        ),
        backgroundColor: AppColors.darkBlue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.beige),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.darkBlue))
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: TextStyle(fontSize: 16, color: AppColors.teal),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchOrders,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkBlue,
                foregroundColor: AppColors.beige,
              ),
              child: Text('Retry'),
            ),
          ],
        ),
      )
          : _orders.isEmpty
          ? Center(
        child: Text(
          'No paid orders found',
          style: TextStyle(fontSize: 18, color: AppColors.teal),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          final String orderId = order['orderId']?.toString() ?? 'Unknown';
          final String totalPrice = order['totalPrice']?.toString() ?? '0';
          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(
                'Order ID: $orderId',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
              subtitle: Text(
                'Total: $totalPrice',
                style: TextStyle(color: AppColors.teal),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailScreen(
                      orderId: orderId,
                      phoneNumber: widget.phoneNumber,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}