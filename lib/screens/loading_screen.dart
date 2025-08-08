import 'package:flutter/material.dart';
import '../utils/theme.dart';
import 'home_screen.dart';

class LoadingScreen extends StatefulWidget {
  final String phoneNumber;

  const LoadingScreen({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _startSplash();
  }

  Future<void> _startSplash() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(phoneNumber: widget.phoneNumber),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige, // Set scaffold background to beige
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Kartly',
              style: AppColors.primaryTextStyle().copyWith(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '..',
              style: AppColors.secondaryTextStyle().copyWith(
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}