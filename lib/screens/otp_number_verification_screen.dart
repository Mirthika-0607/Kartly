import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:shopping_mart/utils/theme.dart';
import 'loading_screen.dart';

class VerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String otp;

  const VerificationScreen({
    Key? key,
    required this.phoneNumber,
    required this.otp,
  }) : super(key: key);

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final apiService = ApiService();

    try {
      final response = await apiService.verifyOtp(widget.phoneNumber, _otpController.text);

      if (response['statusCode'] == 200) {
        final data = response['body'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('phoneNumber', widget.phoneNumber);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                data['message'],
                style: AppColors.secondaryTextStyle(),
              ),
              backgroundColor: AppColors.lightBlue,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoadingScreen(phoneNumber: widget.phoneNumber),
            ),
          );
        }
      } else {
        _showError(response['body']['message'] ?? 'Failed to verify OTP');
      }
    } catch (e) {
      _showError('Network error. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppColors.secondaryTextStyle(),
          ),
          backgroundColor: AppColors.lightBlue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Verify OTP',
          style: AppColors.primaryTextStyle(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter the OTP sent to ${widget.phoneNumber}',
                style: AppColors.secondaryTextStyle().copyWith(fontSize: 16),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: AppColors.textFieldDecoration('OTP').copyWith(
                  hintText: 'Enter 4-digit OTP',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the OTP';
                  }
                  if (!RegExp(r'^\d{4}$').hasMatch(value)) {
                    return 'Please enter a valid 4-digit OTP';
                  }
                  return null;
                },
                style: AppColors.primaryTextStyle(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                style: AppColors.primaryButtonStyle(),
                child: _isLoading
                    ? const CircularProgressIndicator(color: AppColors.beige)
                    : const Text('Verify OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}