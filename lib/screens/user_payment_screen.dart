import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';
import './payment_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String orderId;
  final String phoneNumber;
  final double totalPrice;

  const PaymentScreen({
    Key? key,
    required this.orderId,
    required this.phoneNumber,
    required this.totalPrice,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool isLoading = false;
  bool isOtpSent = false;
  String? otpError;

  @override
  void dispose() {
    _amountController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _generateOtp() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter an amount'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid amount'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
      otpError = null;
    });

    try {
      final otpResult = await ApiService().generateOtp(widget.phoneNumber);
      if (otpResult['statusCode'] == 200 && mounted) {
        setState(() {
          isOtpSent = true;
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP sent to ${widget.phoneNumber}'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Failed to generate OTP: ${otpResult['body']['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate OTP: $e'),
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyOtpAndProcessPayment() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      setState(() {
        otpError = 'Please enter the OTP';
      });
      return;
    }

    setState(() {
      isLoading = true;
      otpError = null;
    });

    try {
      final verifyResult = await ApiService().verifyOtp(widget.phoneNumber, otp);
      if (verifyResult['statusCode'] == 200  && mounted) {
        final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
        final paymentResult = await ApiService().mockPayment(context, widget.phoneNumber, widget.orderId, amount);
        if (paymentResult != null && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentSuccessScreen(
                orderId: widget.orderId,
                phoneNumber: widget.phoneNumber,
                amount: amount,
              ),
            ),
          );
        }
      } else {
        throw Exception('OTP verification failed: ${verifyResult['body']['message'] ?? 'Invalid OTP'}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {
          isLoading = false;
          otpError = 'Invalid OTP';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make Payment', style: TextStyle(color: AppColors.beige)),
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
              'Order ID: ${widget.orderId}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBlue,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Total Amount Due: ${widget.totalPrice}',
              style: TextStyle(fontSize: 16, color: AppColors.teal),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Enter Payment Amount',
                labelStyle: TextStyle(color: AppColors.teal),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.darkBlue),
                ),
                enabled: !isOtpSent, // Disable amount field after OTP is sent
              ),
              style: TextStyle(color: AppColors.darkBlue),
            ),
            if (isOtpSent) ...[
              SizedBox(height: 16),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter OTP',
                  labelStyle: TextStyle(color: AppColors.teal),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.darkBlue),
                  ),
                  errorText: otpError,
                ),
                style: TextStyle(color: AppColors.darkBlue),
              ),
            ],
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : (isOtpSent ? _verifyOtpAndProcessPayment : _generateOtp),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkBlue,
                foregroundColor: AppColors.beige,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: isLoading
                  ? CircularProgressIndicator(color: AppColors.beige)
                  : Text(
                isOtpSent ? 'Verify OTP and Pay' : 'Pay',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}