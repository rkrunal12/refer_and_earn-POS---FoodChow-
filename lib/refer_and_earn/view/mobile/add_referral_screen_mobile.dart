import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:refer_and_earn/refer_and_earn/view/widgets/send_all_button.dart';
import 'package:validate_phone_number/validation.dart';
import '../../color_class.dart';

import '../../controller/provider/refer_provider.dart';
import '../../model/referred_restrauant_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_toast.dart';
import '../widgets/mobile_app_baar.dart';
import '../widgets/referral_list.dart';
import '../widgets/text_field_column.dart';

class AddReferralScreenMobile extends StatefulWidget {
  const AddReferralScreenMobile({super.key});

  @override
  State<AddReferralScreenMobile> createState() => _AddReferralScreenMobileState();
}

class _AddReferralScreenMobileState extends State<AddReferralScreenMobile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ReferralProvider>(context, listen: false);
      if (provider.referrals.isEmpty) provider.addReferral();
    });
  }

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
    return Scaffold(
      appBar: MobileAppBar(title: "Add Referred Restaurant"),
      backgroundColor: ColorsClass.white,
      body: Consumer<ReferralProvider>(
        builder: (context, provider, _) {
          if (provider.referrals.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            });
            return const SizedBox.shrink();
          }
          final referrals = provider.referrals;
          final referral = provider.referrals[0];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: provider.addReferral,
                        child: Container(
                          height: 36,
                          width: 130,
                          decoration: BoxDecoration(color: ColorsClass.primary, borderRadius: BorderRadius.circular(5)),
                          child: Center(
                            child: Text(
                              "+ Add More",
                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: ColorsClass.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (referrals.length > 1)
                  Expanded(
                    child: Card(
                      elevation: 3,
                      color: ColorsClass.white,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(color: ColorsClass.deviderColor, thickness: 1),
                          const SizedBox(height: 6),
                          const Expanded(child: ReferralListAddReferral()),
                          const SizedBox(height: 8),
                          SizedBox(width: double.infinity, child: SendAllButton()),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        provider.referrals.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFieldColumn(
                                    hint: "Enter Restaurant Name",
                                    label: "Restaurant Name",
                                    controller: referral.nameController,
                                    type: TextInputType.name,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFieldColumn(
                                    isPhone: true,
                                    mobile: true,
                                    hint: "Enter Mobile No.",
                                    label: "Mobile No.",
                                    controller: referral.mobileController,
                                    type: TextInputType.phone,
                                    onIsoCodeChanged: (code) {
                                      referral.isoCode = code ?? "IN";
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  TextFieldColumn(
                                    hint: "Enter Email",
                                    label: "Email",
                                    controller: referral.emailController,
                                    type: TextInputType.emailAddress,
                                  ),
                                ],
                              ),

                        const Spacer(),

                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: CustomButton(
                              value: "Save",
                              color: ColorsClass.primary,
                              onTap: () async {
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

                                if (!isValid) {
                                  CustomeToast.showError("Invalid mobile number");
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
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
