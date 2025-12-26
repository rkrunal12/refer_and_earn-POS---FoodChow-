import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../color_class.dart';
import '../../model/referral_row_data.dart';
import 'custom_button.dart';
import 'text_field_column.dart';
import '../../../reponsive.dart';

/// Single row widget
class ReferralRow extends StatelessWidget {
  final int index;
  final ReferralRowData referral;
  final VoidCallback onSend;
  final VoidCallback onDelete;

  const ReferralRow({super.key, required this.index, required this.referral, required this.onSend, required this.onDelete});

  Widget referralRowMobile({required ReferralRowData referral, required VoidCallback onSend, required VoidCallback onDelete}) {
    return Form(
      key: referral.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFieldColumn(
            hint: "Enter Restaurant Name",
            label: "Restaurant Name",
            controller: referral.nameController,
            type: TextInputType.name,
            validator: (val) {
              if (val == null || val.trim().isEmpty) return "Enter Name";
              if (!RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(val.trim())) return "Invalid Name";
              return null;
            },
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
            validator: (val) {
              if (val == null || val.trim().isEmpty) return "Enter Mobile";
              return null;
            },
          ),
          TextFieldColumn(
            hint: "Enter Email",
            label: "Email",
            controller: referral.emailController,
            type: TextInputType.emailAddress,
            validator: (val) {
              if (val == null || val.trim().isEmpty) return "Enter Email";
              if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) return "Invalid Email";
              return null;
            },
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return referralRowMobile(referral: referral, onSend: onSend, onDelete: onDelete);
    } else {
      return Form(
        key: referral.formKey,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFieldColumn(
                hint: "Enter Restaurant Name",
                label: "Restaurant Name",
                controller: referral.nameController,
                type: TextInputType.name,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return "Enter Name";
                  if (!RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(val.trim())) return "Invalid Name";
                  return null;
                },
              ),
            ),
            Expanded(
              flex: 2,
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
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return "Enter Mobile";
                  return null;
                },
              ),
            ),
            Expanded(
              flex: 2,
              child: TextFieldColumn(
                hint: "Enter Email",
                label: "Email",
                controller: referral.emailController,
                type: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return "Enter Email";
                  if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) return "Invalid Email";
                  return null;
                },
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: CustomButton(height: 45, value: "Send", color: ColorsClass.primary, onTap: onSend, width: double.infinity),
              ),
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
        ),
      );
    }
  }
}
