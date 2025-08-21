import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/phone_number_generate_screen.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../utils/theme.dart';

class ApiService {
  static const String _baseUrl = 'http://test0.gpstrack.in:8004';

  Future<String?> getUserPhoneNumber(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phoneNumber');
    if (phoneNumber == null) {
      showError(context, 'No phone number found. Please log in again.');
      _navigateToGenerateScreen(context);
      return null;
    }
    return phoneNumber;
  }


  Future<Map<String, dynamic>> generateNumber(String phoneNumber) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/number/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phoneNumber': phoneNumber}),
    );
    return {
      'statusCode': response.statusCode,
      'body': jsonDecode(response.body),
    };
  }


  Future<Map<String, dynamic>> generateOtp(String phoneNumber) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/otp/generate/$phoneNumber'),
      headers: {'Content-Type': 'application/json'},
    );
    return {
      'statusCode': response.statusCode,
      'body': jsonDecode(response.body),
    };
  }


  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/number/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phoneNumber': phoneNumber,
        'otp': otp,
      }),
    );
    return {
      'statusCode': response.statusCode,
      'body': jsonDecode(response.body),
    };
  }


  Future<List<Product>> fetchProducts(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');


    if (token == null) {
      showError(context, 'No token found. Please log in again.');
      _navigateToGenerateScreen(context);
      return [];
    }


    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/product_array/getdata'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );


      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Product.fromJson(item)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        showError(context, errorData['message'] ?? 'Failed to fetch products');
        return [];
      }
    } catch (e) {
      print(e.toString());
      showError(context, 'Network error. Please try again.');
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchProductRating(BuildContext context, String productId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/product_array/getavgrating'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer your_token', // Replace with actual token
        },
        body: jsonEncode({'productId': productId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch product rating: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching product rating: $e');
      return null;
    }
  }


  Future<List<Map<String, dynamic>>> fetchWishlist(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');


    if (token == null) {
      showError(context, 'No token found. Please log in again.');
      _navigateToGenerateScreen(context);
      return [];
    }


    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/wishlist/get'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );


      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        final errorData = jsonDecode(response.body);
        showError(context, errorData['message'] ?? 'Failed to fetch wishlist');
        return [];
      }
    } catch (e) {
      showError(context, 'Network error. Please try again.');
      return [];
    }
  }


  Future<void> addToWishlist(BuildContext context, String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');


    if (token == null) {
      showError(context, 'No token found. Please log in again.');
      _navigateToGenerateScreen(context);
      return;
    }


    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/wishlist/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'productId': productId}),
      );


      if (response.statusCode == 200) {
        showSuccess(context, 'Added to wishlist');
      } else {
        final errorData = jsonDecode(response.body);
        showError(context, errorData['message'] ?? 'Failed to add to wishlist');
      }
    } catch (e) {
      showError(context, 'Network error. Please try again.');
    }
  }


  Future<void> removeFromWishlist(BuildContext context,
      String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');


    if (token == null) {
      showError(context, 'No token found. Please log in again.');
      _navigateToGenerateScreen(context);
      return;
    }


    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/wishlist/remove'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'productId': productId}),
      );


      if (response.statusCode == 200) {
        showSuccess(context, 'Removed from wishlist');
      } else {
        final errorData = jsonDecode(response.body);
        showError(
            context, errorData['message'] ?? 'Failed to remove from wishlist');
      }
    } catch (e) {
      showError(context, 'Network error. Please try again.');
    }
  }


  Future<User?> fetchUserProfile(BuildContext context,
      String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');


    if (token == null) {
      showError(context, 'No token found. Please log in again.');
      _navigateToGenerateScreen(context);
      return null;
    }


    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "user": {
            "phoneNumber": phoneNumber,
            "token": token,
          },
        }),
      );


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        showError(
            context, errorData['message'] ?? 'Failed to fetch user profile');
        return null;
      }
    } catch (e) {
      showError(context, 'Network error. Please try again.');
      return null;
    }
  }


  Future<bool> createOrUpdateUser(BuildContext context,
      Map<String, dynamic> userData, String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');


    if (token == null) {
      showError(context, 'No token found. Please log in again.');
      _navigateToGenerateScreen(context);
      return false;
    }


    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/user/register'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          ...userData,
          'phoneNumber': phoneNumber,
          'token': token,
        }),
      );


      if (response.statusCode == 201) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonDecode(response.body)['message'])),
          );
        }
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        showError(
            context, errorData['message'] ?? 'Failed to save user profile');
        return false;
      }
    } catch (e) {
      showError(context, 'Network error. Please try again.');
      return false;
    }
  }


  Future<void> logout(BuildContext context, String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/logout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );


      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        await prefs.remove('phoneNumber');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonDecode(response.body)['message'])),
          );
          _navigateToGenerateScreen(context);
        }
      } else {
        final errorData = jsonDecode(response.body);
        showError(context, errorData['message'] ?? 'Failed to logout');
      }
    } catch (e) {
      showError(context, 'Network error. Please try again.');
    }
  }

  Future<Map<String, dynamic>?> addOrUpdateCart(BuildContext context, String productId, String? action) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final phoneNumber = prefs.getString('phoneNumber');

    if (token == null || phoneNumber == null) {
      showError(context, 'No token or phone number found. Please log in again.');
      _navigateToGenerateScreen(context);
      return null;
    }

    try {
      final body = {
        'productId': productId,
        'phoneNumber': phoneNumber,
        if (action != null) 'action': action,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/cart_array/addorupdate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        showError(context, errorData['message'] ?? 'Failed to add/update cart');
        return null;
      }
    } catch (e) {
      debugPrint('Error in addOrUpdateCart: $e');
      showError(context, 'Network error. Please try again.');
      return null;
    }
  }

  Future<Map<String, dynamic>?> removeCartItem(BuildContext context, String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final phoneNumber = prefs.getString('phoneNumber');

    if (token == null || phoneNumber == null) {
      showError(context, 'No token or phone number found. Please log in again.');
      _navigateToGenerateScreen(context);
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/cart_array/removeitem'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'productId': productId,
          'phoneNumber': phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        showError(context, errorData['message'] ?? 'Failed to remove item from cart');
        return null;
      }
    } catch (e) {
      debugPrint('Error in removeCartItem: $e');
      showError(context, 'Network error. Please try again.');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getCartList(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final phoneNumber = prefs.getString('phoneNumber');

    if (token == null || phoneNumber == null) {
      showError(context, 'No token or phone number found. Please log in again.');
      _navigateToGenerateScreen(context);
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/cart_array/getdata'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          return [data]; // Wrap single cart object in a list for consistency
        } else {
          showError(context, 'Invalid cart data format');
          return null;
        }
      } else {
        final errorData = jsonDecode(response.body);
        showError(context, errorData['message'] ?? 'Failed to fetch cart');
        return null;
      }
    } catch (e) {
      debugPrint('Error in getCartList: $e');
      showError(context, 'Network error. Please try again.');
      return null;
    }
  }

  Future<void> deleteCart(BuildContext context, String cartId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final phoneNumber = prefs.getString('phoneNumber');

    if (token == null || phoneNumber == null) {
      showError(context, 'No token or phone number found. Please log in again.');
      _navigateToGenerateScreen(context);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/cart_array/delete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'cartId': cartId,
          'phoneNumber': phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        showSuccess(context, 'Cart cleared');
      } else {
        final errorData = jsonDecode(response.body);
        showError(context, errorData['message'] ?? 'Failed to clear cart');
      }
    } catch (e) {
      debugPrint('Error in deleteCart: $e');
      showError(context, 'Network error. Please try again.');
    }
  }


  Future<Map<String, dynamic>?> addOrUpdateOrder(BuildContext context, {required String phoneNumber, String? orderId, String? productId, String? action}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      showError(context, 'No token found. Please log in again.');
      _navigateToGenerateScreen(context);
      return null;
    }

    try {
      final body = {
        'phoneNumber': phoneNumber,
        if (orderId != null) 'orderId': orderId,
        if (productId != null) 'productId': productId,
        if (action != null) 'action': action,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/order_array/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        showError(context, errorData['message'] ?? 'Failed to add/update order');
        return null;
      }
    } catch (e) {
      debugPrint('Error in addOrUpdateOrder: $e');
      showError(context, 'Network error. Please try again.');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getOrders(BuildContext context, String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      showError(context, 'No token found. Please log in again.');
      _navigateToGenerateScreen(context);
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/order_array/getdata'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else {
          showError(context, 'Invalid order data format');
          return null;
        }
      } else {
        final errorData = jsonDecode(response.body);
        showError(context, errorData['message'] ?? 'Failed to fetch orders');
        return null;
      }
    } catch (e) {
      debugPrint('Error in getOrders: $e');
      showError(context, 'Network error. Please try again.');
      return null;
    }
  }

  Future<Map<String, dynamic>?> deleteOrder(BuildContext context, String phoneNumber, String orderId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      showError(context, 'No token found. Please log in again.');
      _navigateToGenerateScreen(context);
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/order_array/delete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'orderId': orderId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        showError(context, errorData['message'] ?? 'Failed to delete order');
        return null;
      }
    } catch (e) {
      debugPrint('Error in deleteOrder: $e');
      showError(context, 'Network error. Please try again.');
      return null;
    }
  }

  Future<Map<String, dynamic>?> mockPayment(BuildContext context, String phoneNumber, String orderId, double amount) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      showError(context, 'No token found. Please log in again.');
      _navigateToGenerateScreen(context);
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/order_array/mockpayment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'orderId': orderId,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        showError(context, errorData['message'] ?? 'Failed to process payment');
        return null;
      }
    } catch (e) {
      debugPrint('Error in mockPayment: $e');
      showError(context, 'Network error. Please try again.');
      return null;
    }
  }

  Future<Map<String, dynamic>?> checkPaymentSuccess(BuildContext context, String phoneNumber, String orderId, double amount) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      showError(context, 'No token found. Please log in again.');
      _navigateToGenerateScreen(context);
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/order_array/paymentsuccess'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'orderId': orderId,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        showError(context, errorData['message'] ?? 'Failed to check payment');
        return null;
      }
    } catch (e) {
      debugPrint('Error in checkPaymentSuccess: $e');
      showError(context, 'Network error. Please try again.');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createReview(
      BuildContext context, {
        required String productId,
        required int userRating,
        required String userReview,
      }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      showError(context, 'No token found. Please log in again.');
      _navigateToGenerateScreen(context);
      return null;
    }
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/review_array/createreview'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'productId': productId,
          'userRating': userRating,
          'userReview': userReview,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create review: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error creating review: $e');
      throw e;
    }
  }



  Future<List<dynamic>?> fetchProductReviews(BuildContext context, String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      showError(context, 'No token found. Please log in again.');
      _navigateToGenerateScreen(context);
      return null;
    }
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/review_array/getreview'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'productId': productId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          return data;
        } else if (data is Map<String, dynamic> && data['reviews'] is List) {
          return data['reviews'];
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to fetch product reviews: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching product reviews: $e');
      return null;
    }
  }




  static void showError(BuildContext context, String message,
      {bool isError = true}) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(
              color: AppColors.beige,
              fontSize: 16,
            ),
          ),
          backgroundColor: isError ? Colors.red : AppColors.teal,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }


  static void showSuccess(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }


  static void _navigateToGenerateScreen(BuildContext context) {
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GenerateScreen()),
      );
    }
  }
}
