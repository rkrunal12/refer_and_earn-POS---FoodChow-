import 'package:flutter/material.dart';

///*************** Data class ************///
class ReferralRowData {
  final TextEditingController nameController;
  final TextEditingController mobileController;
  final TextEditingController emailController;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String isoCode = "IN";

  ReferralRowData({String restaurantName = '', String mobile = '', String email = ''})
    : nameController = TextEditingController(text: restaurantName),
      mobileController = TextEditingController(text: mobile),
      emailController = TextEditingController(text: email);

  void clear() {
    nameController.clear();
    mobileController.clear();
    emailController.clear();
  }

  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
  }
}
