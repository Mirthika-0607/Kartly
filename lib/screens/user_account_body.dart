import 'package:flutter/material.dart';
import 'package:shopping_mart/services/api_service.dart';
import 'package:shopping_mart/models/user_model.dart';
import 'package:shopping_mart/utils/theme.dart';

class AccountScreen extends StatefulWidget {
  final String phoneNumber;
  const AccountScreen({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  User? _user;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await ApiService().fetchUserProfile(context, widget.phoneNumber);
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
          if (user != null) {
            _nameController.text = user.name ?? '';
            _emailController.text = user.email ?? '';
            _addressController.text = user.address ?? '';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load profile: $e';
        });
      }
    }
  }

  Future<void> _saveUserProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final userData = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'address': _addressController.text.trim(),
    };

    try {
      final success = await ApiService().createOrUpdateUser(context, userData, widget.phoneNumber);
      if (mounted && success) {
        setState(() {
          _isEditing = false;
          _isLoading = false;
        });
        await _fetchUserProfile(); // Refresh profile after update
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to update profile: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.darkBlue))
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.teal,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 200, // Reduced button width
              child: ElevatedButton(
                onPressed: _fetchUserProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBlue,
                  foregroundColor: AppColors.beige,
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.beige,
                    inherit: true,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text('Retry'),
              ),
            ),
          ],
        ),
      )
          : _user == null
          ? Center(
        child: Text(
          'No user data available',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.teal,
          ),
        ),
      )
          : Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 400, // Fixed width for card to ensure centering
                child: Card(
                  color: AppColors.beige,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: _isEditing
                        ? Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              labelStyle: TextStyle(color: AppColors.teal),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.darkBlue),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.darkBlue),
                              ),
                            ),
                            style: TextStyle(color: AppColors.darkBlue),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: AppColors.teal),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.darkBlue),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.darkBlue),
                              ),
                            ),
                            style: TextStyle(color: AppColors.darkBlue),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your email';
                              }
                              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                              if (!emailRegex.hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _addressController,
                            decoration: InputDecoration(
                              labelText: 'Address',
                              labelStyle: TextStyle(color: AppColors.teal),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.darkBlue),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.darkBlue),
                              ),
                            ),
                            style: TextStyle(color: AppColors.darkBlue),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your address';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    )
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Name: ${_user!.name ?? 'Not set'}',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.darkBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Phone: ${_user!.phoneNumber ?? 'Not set'}',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Email: ${_user!.email ?? 'Not set'}',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Address: ${_user!.address ?? 'Not set'}',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Joined: ${_user!.createdAt != null ? _user!.createdAt!.toString().split(' ')[0] : 'Not set'}',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.darkBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200, // Reduced button width
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = !_isEditing;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkBlue,
                        foregroundColor: AppColors.beige,
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.beige,
                          inherit: true,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(_isEditing ? 'Cancel' : 'Edit Profile'),
                    ),
                  ),
                  if (_isEditing) const SizedBox(height: 16),
                  if (_isEditing)
                    SizedBox(
                      width: 200, // Reduced button width
                      child: ElevatedButton(
                        onPressed: _saveUserProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkBlue,
                          foregroundColor: AppColors.beige,
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.beige,
                            inherit: true,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text('Save'),
                      ),
                    ),
                  if (!_isEditing) const SizedBox(height: 16),
                  if (!_isEditing)
                    SizedBox(
                      width: 200, // Reduced button width
                      child: ElevatedButton(
                        onPressed: () => ApiService().logout(context, widget.phoneNumber),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          foregroundColor: AppColors.beige,
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.beige,
                            inherit: true,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text('Logout'),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}