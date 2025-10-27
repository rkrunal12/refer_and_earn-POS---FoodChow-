import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../widgets/campaign_widgets.dart';
import '../widgets/common_widgets.dart';
import '../widgets/referral_widget.dart';
import 'add_referral_screen.dart';

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
      Provider.of<ReferralProvider>(
        context,
        listen: false,
      ).fetchRestaurantReferralData(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 550;
    final referProvider = Provider.of<ReferralProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CustomText(
                text: "Dashboard",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddReferralScreen(),
                  ),
                ),
                child: Container(
                  height: 40,
                  width: 100,
                  decoration: BoxDecoration(
                    color: ColorsClass.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: CustomText(
                      text: "+ Add",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: ColorsClass.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          isMobile
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CampaignDetailed(
                      title: "Total Referrals ",
                      number: referProvider.referralList.length.toString(),
                    ),
                    const SizedBox(height: 10),
                    CampaignDetailed(
                      title: "Successfully Referrals",
                      number: referProvider.activeRefer.length.toString(),
                    ),
                    const SizedBox(height: 10),
                    CampaignDetailed(
                      title: "Pending Referrals",
                      number: referProvider.inactiveRefer.length.toString(),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CampaignDetailed(
                        title: "Total Referrals ",
                        number: referProvider.referralList.length.toString(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CampaignDetailed(
                        title: "Successfully Referrals",
                        number: referProvider.activeRefer.length.toString(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CampaignDetailed(
                        title: "Pending Referrals",
                        number: referProvider.inactiveRefer.length.toString(),
                      ),
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
                      return CircularProgressIndicator.adaptive();
                    }
                    if (provider.referralError != null) {
                      return Text(provider.referralError!);
                    }
                    if (provider.referralList.isEmpty) {
                      return const Center(child: Text("NO DATA"));
                    }
                    return SingleChildScrollView(
                      child: CustomTableRestaurant(list: provider.referralList),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
