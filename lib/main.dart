import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_mart/screens/phone_number_generate_screen.dart';
import 'package:shopping_mart/screens/home_screen.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final phoneNumber = prefs.getString('phoneNumber');
  runApp(MyApp(isLoggedIn: token != null && phoneNumber != null, phoneNumber: phoneNumber));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? phoneNumber;

  const MyApp({Key? key, required this.isLoggedIn, this.phoneNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kartly',
      theme: AppColors.getTheme(), // Use the theme from AppColors
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? HomeScreen(phoneNumber: phoneNumber!) : const GenerateScreen(),
    );
  }
}