import 'package:flutter/material.dart';

///*************** Data class ************///
class ReferralRowData {
  final TextEditingController nameController;
  final TextEditingController mobileController;
  final TextEditingController emailController;

  String isoCode = "IN";

  ReferralRowData({
    String restaurantName = '',
    String mobile = '',
    String email = '',
  }) : nameController = TextEditingController(text: restaurantName),
       mobileController = TextEditingController(text: mobile),
       emailController = TextEditingController(text: email);

  /// Clear all the text fields
  void clear() {
    nameController.clear();
    mobileController.clear();
    emailController.clear();
  }

  /// Dispose all controllers
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
  }

  /// Convert current row data to a Map
  Map<String, String> toMap() {
    return {
      'restaurantName': nameController.text,
      'mobile': mobileController.text,
      'email': emailController.text,
    };
  }
}
