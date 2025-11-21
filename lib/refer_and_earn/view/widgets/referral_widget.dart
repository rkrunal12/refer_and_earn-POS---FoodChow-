import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:refer_and_earn/refer_and_earn/view/widgets/common_widget.dart';
import 'package:validate_phone_number/validation.dart';
import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../../model/referral_row_data.dart';
import '../../model/referred_restrauant_model.dart';

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

              String cleanNumber = rawNumber.replaceAll(
                RegExp(r'[\s\-\(\)]'),
                '',
              );

              bool isValid = Validator.validatePhoneNumber(
                cleanNumber,
                referral.isoCode,
              );

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

/// Single row widget
class ReferralRow extends StatelessWidget {
  final int index;
  final ReferralRowData referral;
  final VoidCallback onSend;
  final VoidCallback onDelete;

  const ReferralRow({
    super.key,
    required this.index,
    required this.referral,
    required this.onSend,
    required this.onDelete,
  });

  Widget referralRowMobile({
    required ReferralRowData referral,
    required VoidCallback onSend,
    required VoidCallback onDelete,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFieldColumn(
          hint: "Enter Restaurant Name",
          label: "Restaurant Name",
          controller: referral.nameController,
          type: TextInputType.name,
        ),
        TextFieldColumn(
          mobile: true,
          isPhone: true,
          hint: "Enter Mobile No.",
          label: "Mobile No.",
          controller: referral.mobileController,
          type: TextInputType.phone,
          onIsoCodeChanged: (code) {
            referral.isoCode = code ?? "IN";
          },
        ),
        TextFieldColumn(
          hint: "Enter Email",
          label: "Email",
          controller: referral.emailController,
          type: TextInputType.emailAddress,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onDelete,
                  child: Container(
                    height: 50,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Color(0xFFFC0005)),
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                    ),
                    child: Center(
                      child: CustomText(
                        text: "Delete",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: const Color(0xFFFC0005),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: onSend,
                  child: CustomButton(
                    value: "Send",
                    color: ColorsClass.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 700;

        if (isSmallScreen) {
          return referralRowMobile(
            referral: referral,
            onSend: onSend,
            onDelete: onDelete,
          );
        } else {
          return Row(
            children: [
              Expanded(
                flex: 1,
                child: TextFieldColumn(
                  hint: "Enter Restaurant Name",
                  label: "Restaurant Name",
                  controller: referral.nameController,
                  type: TextInputType.name,
                ),
              ),
              Expanded(
                flex: 1,
                child: TextFieldColumn(
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
              ),
              Expanded(
                flex: 1,
                child: TextFieldColumn(
                  hint: "Enter Email",
                  label: "Email",
                  controller: referral.emailController,
                  type: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: onSend,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: CustomButton(
                    value: "Send",
                    color: ColorsClass.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onDelete,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: SizedBox(
                    height: 45,
                    width: 45,
                    child: SvgPicture.asset("assets/svg/mobile_delete.svg"),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

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
        return GestureDetector(
          onTap: () async {
            final referrals = List.of(value.referrals);

            for (int i = 0; i < referrals.length; i++) {
              ReferralRowData referral = referrals[i];

              if (!validateField(referral.nameController, 'name')) {
                CustomeToast.showError('Form ${i + 1}: Enter a valid name');
                return;
              }

              String rawNumber = referral.mobileController.text.trim();
              String cleanNumber = rawNumber.replaceAll(
                RegExp(r'[\s\-\(\)]'),
                '',
              );

              bool isValid = Validator.validatePhoneNumber(
                cleanNumber,
                referral.isoCode,
              );

              if (!isValid) {
                CustomeToast.showError(
                  'Form ${i + 1}: Enter phone number properly',
                );
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
          child: CustomButton(value: "Send All", color: ColorsClass.primary),
        );
      },
    );
  }
}
