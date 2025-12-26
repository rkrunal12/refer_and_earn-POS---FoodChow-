import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:validate_phone_number/validation.dart';
import '../../controller/provider/refer_provider.dart';
import '../../model/referred_restrauant_model.dart';
import 'custom_toast.dart';
import 'referral_row.dart';

/// List of referral rows
class ReferralListAddReferral extends StatelessWidget {
  const ReferralListAddReferral({super.key});

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
      builder: (context, provider, _) {
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: provider.referrals.length,
          itemBuilder: (context, index) {
            final referral = provider.referrals[index];

            void onSend() async {
              if (!validateField(referral.nameController, 'name')) {
                CustomeToast.showError('Enter a valid name');
                return;
              }

              String rawNumber = referral.mobileController.text.trim();

              String cleanNumber = rawNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');

              bool isValid = Validator.validatePhoneNumber(cleanNumber, referral.isoCode);

              if (!isValid) {
                CustomeToast.showError("Enter Phone number properly");
                return;
              }

              if (!validateField(referral.emailController, 'email')) {
                CustomeToast.showError('Enter a valid email');
                return;
              }

              ReferredRestaurantsModel data = ReferredRestaurantsModel(
                referringRestaurantId: "7866",
                mobile: referral.mobileController.text,
                email: referral.emailController.text,
                name: referral.nameController.text,
              );

              await provider.addRestaurantReferralData(data);
              referral.clear();
              referral.dispose();
              provider.removeReferral(index);

              Navigator.pop(context);
            }

            return ReferralRow(
              index: index,
              referral: referral,
              onSend: onSend,
              onDelete: () {
                provider.removeReferral(index);
              },
            );
          },
        );
      },
    );
  }
}

