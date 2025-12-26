import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';

import '../widgets/custome_referal_table_restaurant.dart';
import 'add_referral_screen.dart';
import '../../../reponsive.dart';

class RestraurentReferal extends StatefulWidget {
  const RestraurentReferal({super.key});

  @override
  State<RestraurentReferal> createState() => _RestraurentReferalState();
}

class _RestraurentReferalState extends State<RestraurentReferal> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ReferralProvider>(context, listen: false);
      if (provider.referralList.isEmpty) {
        provider.fetchRestaurantReferralData(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final referProvider = Provider.of<ReferralProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final smallScreen = Responsive.isMobile(context);
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Dashboard", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500)),
                  InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddReferralScreen())),
                    child: Container(
                      height: 40,
                      width: 100,
                      decoration: BoxDecoration(color: ColorsClass.primary, borderRadius: BorderRadius.circular(4)),
                      child: Center(
                        child: Text(
                          "+ Add",
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: ColorsClass.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              smallScreen
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _CampaignDetailedCampaignInfo(title: "Total Referrals", number: referProvider.referralList.length.toString()),
                        const SizedBox(height: 10),
                        _CampaignDetailedCampaignInfo(title: "Successfully Referrals", number: referProvider.activeRefer.length.toString()),
                        const SizedBox(height: 10),
                        _CampaignDetailedCampaignInfo(title: "Pending Referrals", number: referProvider.pendingRefer.length.toString()),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _CampaignDetailedCampaignInfo(title: "Total Referrals", number: referProvider.referralList.length.toString()),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _CampaignDetailedCampaignInfo(title: "Successfully Referrals", number: referProvider.activeRefer.length.toString()),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _CampaignDetailedCampaignInfo(title: "Pending Referrals", number: referProvider.pendingRefer.length.toString()),
                        ),
                      ],
                    ),

              const SizedBox(height: 10),

              Expanded(
                child: Card(
                  color: ColorsClass.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Consumer<ReferralProvider>(
                      builder: (context, provider, _) {
                        if (provider.isReferralLoading) {
                          return const Center(child: CircularProgressIndicator.adaptive());
                        }

                        if (provider.referralList.isEmpty) {
                          return const Center(child: Text("NO DATA"));
                        }

                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          child: CustomReferralTableRestaurant(list: provider.referralList),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CampaignDetailedCampaignInfo extends StatelessWidget {
  final String title;
  final String number;

  const _CampaignDetailedCampaignInfo({required this.title, required this.number});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Card(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                child: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14)),
              ),
              const SizedBox(height: 10),
              Text(
                number,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 29, color: ColorsClass.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
