
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../color_class.dart';
import '../../model/referral_row_data.dart';
import 'custom_button.dart';
import 'text_field_column.dart';

/// Single row widget
class ReferralRow extends StatelessWidget {
  final int index;
  final ReferralRowData referral;
  final VoidCallback onSend;
  final VoidCallback onDelete;

  const ReferralRow({super.key, required this.index, required this.referral, required this.onSend, required this.onDelete});

  Widget referralRowMobile({required ReferralRowData referral, required VoidCallback onSend, required VoidCallback onDelete}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFieldColumn(hint: "Enter Restaurant Name", label: "Restaurant Name", controller: referral.nameController, type: TextInputType.name),
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
        TextFieldColumn(hint: "Enter Email", label: "Email", controller: referral.emailController, type: TextInputType.emailAddress),
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
                      child: Text(
                        "Delete",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15, color: const Color(0xFFFC0005)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomButton(value: "Send", color: ColorsClass.primary, onTap: onSend),
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
          return referralRowMobile(referral: referral, onSend: onSend, onDelete: onDelete);
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
                child: TextFieldColumn(hint: "Enter Email", label: "Email", controller: referral.emailController, type: TextInputType.emailAddress),
              ),
              const SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: CustomButton(value: "Send", color: ColorsClass.primary, onTap: onSend),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onDelete,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: SizedBox(height: 45, width: 45, child: SvgPicture.asset("assets/svg/mobile_delete.svg")),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
