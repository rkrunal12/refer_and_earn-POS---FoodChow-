import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:validate_phone_number/validation.dart';

import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../../model/referral_row_data.dart';
import '../../model/referred_restrauant_model.dart';
import 'custom_button.dart';
import 'custom_toast.dart';

/// Send all Button
class SendAllButton extends StatelessWidget {
  const SendAllButton({super.key});

  bool validateField(TextEditingController controller, String type) {
    final text = controller.text.trim();
    if (text.isEmpty) return false;
    switch (type) {
      case 'name':
        return RegExp(r'^[a-zA-Z\s]+$').hasMatch(text);
      case 'email':
        return RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(text);
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReferralProvider>(
      builder: (context, value, _) {
        return CustomButton(
          value: "Send All",
          color: ColorsClass.primary,
          onTap: () async {
            final referrals = List.of(value.referrals);

            for (int i = 0; i < referrals.length; i++) {
              ReferralRowData referral = referrals[i];

              if (!validateField(referral.nameController, 'name')) {
                CustomeToast.showError('Form ${i + 1}: Enter a valid name');
                return;
              }

              String rawNumber = referral.mobileController.text.trim();
              String cleanNumber = rawNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');

              bool isValid = Validator.validatePhoneNumber(cleanNumber, referral.isoCode);

              if (!isValid) {
                CustomeToast.showError('Form ${i + 1}: Enter phone number properly');
                return;
              }

              if (!validateField(referral.emailController, 'email')) {
                CustomeToast.showError('Form ${i + 1}: Enter a valid email');
                return;
              }

              ReferredRestaurantsModel data = ReferredRestaurantsModel(
                referringRestaurantId: "7866",
                mobile: cleanNumber,
                email: referral.emailController.text.trim(),
                name: referral.nameController.text.trim(),
              );

              await value.addRestaurantReferralData(data);
            }
            value.clearList();
            value.disposeAll();
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
