import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../color_class.dart';
import '../screens/chat_boat/chatboat_fullscree.dart';
import '../widgets/mobile_widgets.dart';
import 'mobile_all_campaign.dart';
import 'mobile_cashback.dart';
import 'restraurent_referal_mobile.dart';

class MobileReferenceScreen extends StatelessWidget {
  const MobileReferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsClass.white,
      appBar: AppBar(
        backgroundColor: ColorsClass.white,
        leading: const Icon(Icons.menu, color: Colors.black),
        elevation: 1,
        title: Text(
          "Refer & Earn",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Image.asset(
                  "assets/images/refer_and_earn/user.png",
                  height: 24,
                  width: 24,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.person, size: 24, color: Colors.black),
                ),
                const SizedBox(width: 8),
                Text(
                  "Admin",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Refer and Earn",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MobileAllCampaign(),
                    ),
                  );
                },
                child: ContentContainerMobile(
                  leading: SvgPicture.asset(
                    "assets/svg/add.svg",
                    color: ColorsClass.primary,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.add, size: 30),
                  ),
                  title: "Create New Campaign",
                ),
              ),
              const SizedBox(height: 10),

              // "Cashback"
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const MobileCashback(isMobile: true),
                    ),
                  );
                },
                child: ContentContainerMobile(
                  leading: SvgPicture.asset(
                    "assets/svg/cashback.svg",
                    fit: BoxFit.contain,
                    color: ColorsClass.primary,
                  ),
                  title: "Cashback",
                ),
              ),
              const SizedBox(height: 10),

              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RestraurentReferalMobile(),
                    ),
                  );
                },
                child: ContentContainerMobile(
                  leading: SvgPicture.asset(
                    "assets/svg/restaurant.svg",
                    fit: BoxFit.contain,
                    color: ColorsClass.primary,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.restaurant, size: 30),
                  ),
                  title: "Restaurant Referral",
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: ColorsClass.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatboatFullscreen()),
          );
        },
        child: Image.asset("assets/images/charboat.png"),
      ),
    );
  }
}
