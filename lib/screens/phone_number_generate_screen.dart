import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';
import 'otp_number_verification_screen.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({Key? key}) : super(key: key);

  @override
  _GenerateScreenState createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _generateNumberAndOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final phoneNumber = _phoneController.text;
    final apiService = ApiService();

    try {
      final generateResponse = await apiService.generateNumber(phoneNumber);
      if (generateResponse['statusCode'] == 201 || generateResponse['statusCode'] == 409) {
        final otpResponse = await apiService.generateOtp(phoneNumber);
        if (otpResponse['statusCode'] == 200) {
          final otpData = otpResponse['body'];
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VerificationScreen(
                  phoneNumber: phoneNumber,
                  otp: otpData['otp'],
                ),
              ),
            );
          }
        } else {
          _showError(otpResponse['body']['message'] ?? 'Failed to generate OTP');
        }
      } else {
        _showError(generateResponse['body']['message'] ?? 'Failed to add phone number');
      }
    } catch (e) {
      print(e.toString());
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
          'Enter Phone Number',
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
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: AppColors.textFieldDecoration('Phone Number').copyWith(
                  hintText: 'Enter 10-digit phone number',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                    return 'Please enter a valid 10-digit phone number';
                  }
                  return null;
                },
                style: AppColors.primaryTextStyle(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _generateNumberAndOtp,
                style: AppColors.primaryButtonStyle(),
                child: _isLoading
                    ? const CircularProgressIndicator(color: AppColors.beige)
                    : const Text('Generate OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}