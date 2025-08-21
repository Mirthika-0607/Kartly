import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';
import './home_screen.dart'; // Updated import to HomeScreen

class PaymentSuccessScreen extends StatefulWidget {
  final String orderId;
  final String phoneNumber;
  final double amount;

  const PaymentSuccessScreen({
    Key? key,
    required this.orderId,
    required this.phoneNumber,
    required this.amount,
  }) : super(key: key);

  @override
  _PaymentSuccessScreenState createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  Map<String, dynamic>? paymentData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPaymentDetails();
    _navigateAfterDelay();
  }

  Future<void> _fetchPaymentDetails() async {
    try {
      final result = await ApiService().checkPaymentSuccess(context, widget.phoneNumber, widget.orderId, widget.amount);
      if (result != null && mounted) {
        setState(() {
          paymentData = result;
          isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to verify payment: $e'),
          duration: Duration(seconds: 2),
        ),
      );
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            phoneNumber: widget.phoneNumber,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Success', style: TextStyle(color: AppColors.beige)),
        backgroundColor: AppColors.darkBlue,
        automaticallyImplyLeading: false, // No back button
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator(color: AppColors.darkBlue)
            : paymentData == null
            ? Text(
          'Payment verification failed',
          style: TextStyle(fontSize: 18, color: AppColors.teal),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.teal,
              size: 100,
            ),
            SizedBox(height: 16),
            Text(
              paymentData!['message'] ?? 'Payment Successful',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBlue,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Order ID: ${widget.orderId}',
              style: TextStyle(fontSize: 16, color: AppColors.teal),
            ),
            Text(
              'Amount Paid: ${widget.amount}',
              style: TextStyle(fontSize: 16, color: AppColors.teal),
            ),
            Text(
              'Status: ${paymentData!['isPaid'] ? 'Verified' : 'Not Verified'}',
              style: TextStyle(fontSize: 16, color: AppColors.teal),
            ),
            SizedBox(height: 16),
            Text(
              'Redirecting to Home Screen...',
              style: TextStyle(fontSize: 16, color: AppColors.darkBlue),
            ),
          ],
        ),
      ),
    );
  }
}