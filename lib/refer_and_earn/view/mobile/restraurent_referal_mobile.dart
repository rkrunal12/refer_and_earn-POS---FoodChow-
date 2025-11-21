import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';
import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../widgets/common_widget.dart';
import '../widgets/mobile_widgets.dart';
import 'add_referral_screen_mobile.dart';

class RestraurentReferalMobile extends StatefulWidget {
  const RestraurentReferalMobile({super.key});

  @override
  State<RestraurentReferalMobile> createState() =>
      _RestraurentReferalMobileState();
}

class _RestraurentReferalMobileState extends State<RestraurentReferalMobile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReferralProvider>(
        context,
        listen: false,
      ).fetchRestaurantReferralData(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsClass.white,
      appBar: MobileAppBar(title: "Restaurant Referral"),
      body: Column(
        children: [
          SizedBox(height: 10),
          MobileHeader(
            title: "Your Referred Restaurant",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddReferralScreenMobile(),
                ),
              );
            },
            mobileTitle: "+ Add Referral",
          ),
          Expanded(
            child: Card(
              color: ColorsClass.white,
              elevation: 2,
              child: Consumer<ReferralProvider>(
                builder: (context, provider, _) {
                  if (provider.isReferralLoading) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                  if (provider.referralList.isEmpty) {
                    return const Center(
                      child: Text("No Referred Restaurant added"),
                    );
                  }
                  return CustomTableRestaurantMobileReferral(
                    list: provider.referralList,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// mobile header
class MobileHeader extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final String mobileTitle;
  const MobileHeader({
    super.key,
    required this.title,
    required this.onTap,
    required this.mobileTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
          InkWell(
            onTap: onTap,
            child: Container(
              height: 36,
              width: 130,
              decoration: BoxDecoration(
                color: ColorsClass.primary,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Text(
                  mobileTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ColorsClass.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
