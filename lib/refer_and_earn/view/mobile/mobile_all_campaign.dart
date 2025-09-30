import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/provider/refer_provider.dart';
import '../widgets/mobile_widgets.dart';
import 'add_campaign_mobile.dart';

class MobileAllCampaign extends StatefulWidget {
  const MobileAllCampaign({super.key});

  @override
  State<MobileAllCampaign> createState() => _MobileAllCampaignState();
}

class _MobileAllCampaignState extends State<MobileAllCampaign> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReferralProvider>(context, listen: false).fetchData(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const MobileAppBar(title: "Refer and Earn"),
      body: Consumer<ReferralProvider>(
        builder: (context, value, _) {
          if (value.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = value.data;
          if (data.isEmpty) {
            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                  child: MobileHeader(
                    title: "Campaign Details",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddCampaignMobile(isMobile: true,),
                        ),
                      );
                    },
                    mobileTitle: "+ Add Campaign",
                  ),
                ),
                Center(child: Text("No Data")),
              ],
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: data.length + 1, // +1 for the header
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                  child: MobileHeader(
                    title: "Campaign Details",
                    mobileTitle: "+ Add Campaign",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddCampaignMobile(isMobile: true),
                        ),
                      );
                    },
                  ),
                );
              }

              final campaign = data[index - 1]; // subtract 1 because of header
              return MobileCampaignCard(data: campaign);
            },
          );
        },
      ),
    );
  }
}
