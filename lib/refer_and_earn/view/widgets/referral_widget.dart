import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:validate_phone_number/validation.dart';
import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../../model/referral_row_data.dart';
import '../../model/referred_restrauant_model.dart';
import 'common_widgets.dart';
import 'mobile_widgets.dart';

/// Table showing restaurant referrals
class CustomTableRestaurant extends StatelessWidget {
  final List<ReferredRestaurantsModel>? list;

  const CustomTableRestaurant({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 650) {
          return CustomTableRestaurantMobile(list: list, );
        } else {
          // Large screen: keep DataTable
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(const Color(0x550AA89E)),
                headingTextStyle: const TextStyle(
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
    const cellStyle = TextStyle(fontWeight: FontWeight.w400, fontSize: 14);

    return DataRow(cells: [
      DataCell(Center(child: Text(data.name ?? "-", style: cellStyle))),
      DataCell(Center(child: Text(data.mobile ?? "-", style: cellStyle))),
      DataCell(Center(child: Text(data.email ?? "-", style: cellStyle))),
      DataCell(Center(child: Text("NO", style: cellStyle))),
      DataCell(Center(child: Text("Claim(1 Month Free)", style: cellStyle))),
      DataCell(Center(
          child: Container(
            height: 30,
            width: 150,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: data.claimed! ? const Color(0x808DBD90) : const Color(0x80D87E7E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: data.claimed! ? const Color(0xFF007521) : const Color(0xFFFC0005),
                width: 2,
              ),
            ),
            child: Text(data.claimed! ? "Completed" : "Pending",
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ))),
      DataCell(Center(
        child: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () async {
            final deleteData = await Provider.of<ReferralProvider>(context, listen: false)
                .deleteRestaurantReferralData(data.restaurantId);
            CustomSnackBar.show(deleteData, false);
          },
        ),
      )),
    ]);
  }
}

/// Header with title and Add button
class ReferralHeader extends StatelessWidget {
  const ReferralHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReferralProvider>(context, listen: false);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const CustomText(
          text: "Your Referred Restaurants",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
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
            child: const Center(
              child: CustomText(
                text: "+ Add More",
                style: TextStyle(
                  fontSize: 15,
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
class ReferralList extends StatelessWidget {
  final bool isMobile;
  const ReferralList({super.key, required this.isMobile});

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
                CustomSnackBar.show('Enter a valid name', isMobile);
                return;
              }

              String rawNumber = referral.mobileController.text.trim();

              String cleanNumber = rawNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');

              bool isValid = Validator.validatePhoneNumber(
                cleanNumber,
                referral.isoCode,
              );

              if(!isValid){
                CustomSnackBar.show("Enter Phone number properly", isMobile);
                return;
              }

              if (!validateField(referral.emailController, 'email')) {
                CustomSnackBar.show('Enter a valid email', isMobile);
                return;
              }

              ReferredRestaurantsModel data = ReferredRestaurantsModel(
                referringRestaurantId: 123,
                referredBy: "Gourmet Grill",
                mobile: referral.mobileController.text,
                claimed: false,
                email: referral.emailController.text,
                name: referral.nameController.text,
              );

              final addData = await provider.addRestaurantReferralData(data);
              CustomSnackBar.show(addData, isMobile);
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
                referral.dispose();
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

        if(isMobile){
          return  ReferralRowMobile(
            referral: referral,
            onSend: onSend,
            onDelete: onDelete,
          );
        }
        final isSmallScreen = constraints.maxWidth < 850;

        if (isSmallScreen) {
          // Use mobile-specific widget
          return ReferralRowMobile(
            referral: referral,
            onSend: onSend,
            onDelete: onDelete,
          );
        } else {
          // Desktop/tablet layout
          return Row(
            children: [
              Expanded(
                flex: 4,
                child: TextFieldColumn(
                  hint: "Enter Restaurant Name",
                  label: "Restaurant Name",
                  controller: referral.nameController,
                  type: TextInputType.name,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: TextFieldColumn(
                  isPhone: true,
                  mobile: isMobile,
                  hint: "Enter Mobile No.",
                  label: "Mobile No.",
                  controller: referral.mobileController,
                  type: TextInputType.phone,
                  onIsoCodeChanged: (code) {
                    referral.isoCode = code ?? "IN"; // 👈 directly save into referral
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: TextFieldColumn(
                  hint: "Enter Email",
                  label: "Email",
                  controller: referral.emailController,
                  type: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(width: 8),
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
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDelete,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: SizedBox(
                    height: 45,
                    width: 45,
                    child: Image.asset(
                      "assets/images/refer_and_earn/mobile_delete.png",
                    ),
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
    return Consumer<ReferralProvider>(builder: (context, value, _) {
      return GestureDetector(
          onTap: () async {
            // Create a temporary copy so we don’t modify while iterating
            final referrals = List.of(value.referrals);

            for (int i = 0; i < referrals.length; i++) {
              ReferralRowData referral = referrals[i];

              // Validate name
              if (!validateField(referral.nameController, 'name')) {
                CustomSnackBar.show('Form ${i + 1}: Enter a valid name', isMobile);
                return;
              }

              // Clean phone number
              String rawNumber = referral.mobileController.text.trim();
              String cleanNumber = rawNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');

              bool isValid = Validator.validatePhoneNumber(
                cleanNumber,
                referral.isoCode,
              );

              if (!isValid) {
                CustomSnackBar.show('Form ${i + 1}: Enter phone number properly', isMobile);
                return;
              }

              // Validate email
              if (!validateField(referral.emailController, 'email')) {
                CustomSnackBar.show('Form ${i + 1}: Enter a valid email', isMobile);
                return;
              }

              // Prepare model
              ReferredRestaurantsModel data = ReferredRestaurantsModel(
                referringRestaurantId: 123,
                referredBy: "Gourmet Grill",
                mobile: cleanNumber,
                claimed: false,
                email: referral.emailController.text.trim(),
                name: referral.nameController.text.trim(),
              );

              // Send each referral
              final addData = await value.addRestaurantReferralData(data);
              CustomSnackBar.show(addData, isMobile);
            }
            value.clearList();
            value.disposeAll();
            Navigator.pop(context);
          },
          child: CustomButton(value: "Send All", color: ColorsClass.primary),
      );
    },);
  }
}


