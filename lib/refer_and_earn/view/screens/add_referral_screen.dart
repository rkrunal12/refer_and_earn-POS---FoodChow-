import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../../../reponsive.dart';
import '../../model/referred_restrauant_model.dart';
import '../widgets/referral_row.dart';
import '../widgets/send_all_button.dart';

class AddReferralScreen extends StatefulWidget {
  const AddReferralScreen({super.key});

  @override
  State<AddReferralScreen> createState() => _AddReferralScreenState();
}

class _AddReferralScreenState extends State<AddReferralScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ReferralProvider>(context, listen: false);
      if (provider.referrals.isEmpty) provider.addReferral();
    });
  }

  @override
  Widget build(BuildContext context) {
    final smallScreen = Responsive.isMobile(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        title: Text("Refer & Earn", style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 20)),
      ),
      body: Padding(
        padding: smallScreen ? const EdgeInsets.all(0) : const EdgeInsets.all(16.0),
        child: Card(
          elevation: 3,
          color: ColorsClass.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(3))),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Your Referred Restaurants",
                      style: GoogleFonts.poppins(fontSize: smallScreen ? 14 : 20, fontWeight: FontWeight.w500),
                    ),
                    InkWell(
                      onTap: Provider.of<ReferralProvider>(context, listen: false).addReferral,
                      child: Container(
                        height: 40,
                        width: 100,
                        decoration: BoxDecoration(color: ColorsClass.primary, borderRadius: BorderRadius.circular(4)),
                        child: Center(
                          child: Text(
                            "+ Add More",
                            style: GoogleFonts.poppins(fontSize: smallScreen ? 12 : 15, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(color: ColorsClass.deviderColor, thickness: 1),
                const SizedBox(height: 8),
                Expanded(
                  child: Consumer<ReferralProvider>(
                    builder: (context, provider, _) {
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: provider.referrals.length,
                        itemBuilder: (context, index) {
                          final referral = provider.referrals[index];
                          void onSend() async {
                            if (referral.formKey.currentState!.validate()) {
                              String rawNumber = referral.mobileController.text.trim();
                              String cleanNumber = rawNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
                              ReferredRestaurantsModel data = ReferredRestaurantsModel(
                                referringRestaurantId: "7866",
                                mobile: cleanNumber,
                                email: referral.emailController.text,
                                name: referral.nameController.text,
                              );

                              await provider.addRestaurantReferralData(data);
                              referral.clear();

                              Navigator.pop(context);
                            }
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
                  ),
                ),
                const SizedBox(height: 12),
                Consumer<ReferralProvider>(
                  builder: (context, value, child) {
                    if (value.referrals.length > 1) {
                      return const SendAllButton();
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
