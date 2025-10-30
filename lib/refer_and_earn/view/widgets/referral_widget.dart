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
import 'mobile_widgets.dart';

/// Table showing restaurant referrals
class CustomReferralTableRestaurant extends StatelessWidget {
  final List<ReferredRestaurantsModel>? list;

  const CustomReferralTableRestaurant({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 650) {
          return CustomTableRestaurantMobileReferral(list: list);
        } else {
          // Large screen: keep DataTable
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  const Color(0x550AA89E),
                ),
                headingTextStyle: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                border: TableBorder.all(
                  borderRadius: BorderRadius.circular(10),
                  width: 1,
                  color: ColorsClass.tableDevider,
                ),
                columnSpacing: 20,
                columns: const [
                  DataColumn(label: Center(child: Text("Name"))),
                  DataColumn(label: Center(child: Text("Mobile No."))),
                  DataColumn(label: Center(child: Text("Email"))),
                  DataColumn(label: Center(child: Text("Sign Up"))),
                  DataColumn(label: Center(child: Text("Reward"))),
                  DataColumn(label: Center(child: Text("Status"))),
                  DataColumn(label: Center(child: Text("Action"))),
                ],
                rows: list != null && list!.isNotEmpty
                    ? list!.map((data) => _buildDataRow(data, context)).toList()
                    : [],
              ),
            ),
          );
        }
      },
    );
  }

  DataRow _buildDataRow(ReferredRestaurantsModel data, BuildContext context) {
    const cellStyle = TextStyle(fontWeight: FontWeight.w400);

    return DataRow(
      cells: [
        DataCell(Center(child: Text(data.name ?? "-", style: cellStyle))),
        DataCell(Center(child: Text(data.mobile ?? "-", style: cellStyle))),
        DataCell(Center(child: Text(data.email ?? "-", style: cellStyle))),
        DataCell(Center(child: Text("NO", style: cellStyle))),
        DataCell(Center(child: Text("Claim(1 Month Free)", style: cellStyle))),
        DataCell(
          Center(
            child: Container(
              height: 25,
              width: 100,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: data.claimed == 1
                    ? const Color(0x808DBD90)
                    : const Color(0x80D87E7E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: data.claimed == 1
                      ? const Color(0xFF007521)
                      : const Color(0xFFFC0005),
                  width: 2,
                ),
              ),
              child: FittedBox(
                child: Text(
                  data.claimed == 1 ? "Completed" : "Pending",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ),
        ),
        DataCell(
          Center(
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await Provider.of<ReferralProvider>(
                  context,
                  listen: false,
                ).deleteRestaurantReferralData(data.restaurantId, data.id);
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Header with title and Add button
class ReferralHeader extends StatelessWidget {
  const ReferralHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReferralProvider>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 550;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          text: "Your Referred Restaurants",
          style: GoogleFonts.poppins(
            fontSize: isMobile ? 14 : 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        InkWell(
          onTap: provider.addReferral,
          child: Container(
            height: 40,
            width: 100,
            decoration: BoxDecoration(
              color: ColorsClass.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: CustomText(
                text: "+ Add More",
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 12 : 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// List of referral rows
class ReferralListAddReferral extends StatelessWidget {
  const ReferralListAddReferral({super.key, required this.isMobile});

  final bool isMobile;

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
                restaurantId: "7866",
                referringRestaurantId: "123",
                referredBy: "Gourmet Grill",
                mobile: referral.mobileController.text,
                claimed: 0,
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
              isMobile: isMobile,
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
  final bool isMobile;
  final int index;
  final ReferralRowData referral;
  final VoidCallback onSend;
  final VoidCallback onDelete;

  const ReferralRow({
    super.key,
    required this.isMobile,
    required this.index,
    required this.referral,
    required this.onSend,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (isMobile) {
          return ReferralRowMobile(
            referral: referral,
            onSend: onSend,
            onDelete: onDelete,
          );
        }
        final isSmallScreen = constraints.maxWidth < 70;

        if (isSmallScreen) {
          // Use mobile-specific widget
          return ReferralRowMobile(
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
                  mobile: isMobile,
                  hint: "Enter Mobile No.",
                  label: "Mobile No.",
                  controller: referral.mobileController,
                  type: TextInputType.phone,
                  onIsoCodeChanged: (code) {
                    referral.isoCode =
                        code ?? "IN"; // 👈 directly save into referral
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
  const SendAllButton({super.key, required this.isMobile});

  final bool isMobile;

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
            // Create a temporary copy so we don’t modify while iterating
            final referrals = List.of(value.referrals);

            for (int i = 0; i < referrals.length; i++) {
              ReferralRowData referral = referrals[i];

              // Validate name
              if (!validateField(referral.nameController, 'name')) {
                CustomeToast.showError('Form ${i + 1}: Enter a valid name');
                return;
              }

              // Clean phone number
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

              // Validate email
              if (!validateField(referral.emailController, 'email')) {
                CustomeToast.showError('Form ${i + 1}: Enter a valid email');
                return;
              }

              // Prepare model
              ReferredRestaurantsModel data = ReferredRestaurantsModel(
                restaurantId: "7866",
                referringRestaurantId: "123",
                referredBy: "Gourmet Grill",
                mobile: cleanNumber,
                claimed: 0,
                email: referral.emailController.text.trim(),
                name: referral.nameController.text.trim(),
              );

              // Send each referral
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
