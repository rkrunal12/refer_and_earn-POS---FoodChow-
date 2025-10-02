import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
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
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
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
            Card(
              color: ColorsClass.white,
              elevation: 2,
              child: Consumer<ReferralProvider>(
                builder: (context, provider, _) {
                  if (provider.isReferralLoading) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                  if (provider.referralError != null) {
                    return Center(child: Text(provider.referralError!));
                  }
                  if (provider.referralList.isEmpty) {
                    return const Center(child: Text("No Referred Restaurant added"));
                  }
                  return CustomTableRestaurantMobile(
                    list: provider.referralList,
                    isMobile: true,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
