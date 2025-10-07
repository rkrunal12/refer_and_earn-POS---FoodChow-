import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/provider/refer_provider.dart';
import '../widgets/campaign_widgets.dart';
import '../widgets/mobile_widgets.dart';

class AllCampaign extends StatefulWidget {
  const AllCampaign({super.key});

  @override
  State<AllCampaign> createState() => _AllCampaignState();
}

class _AllCampaignState extends State<AllCampaign> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReferralProvider>(context, listen: false).fetchData(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 550;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Card(
          color: Colors.white,
          margin: const EdgeInsets.all(10),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Consumer<ReferralProvider>(
              builder: (context, provider, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Totals row
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: isMobile ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CampaignDetailed(
                            title: "Total Campaigns",
                            number: provider.data.length.toString(),
                          ),
                          CampaignDetailed(
                            title: "Active Campaigns",
                            number: provider.activeCampaigns.length.toString(),
                          ),
                          CampaignDetailed(
                            title: "Total referrals",
                            number: provider.totalReferrals.toString(),
                          ),
                        ],
                      ) :Row(
                        children: [
                          Expanded(
                            child: CampaignDetailed(
                              title: "Total Campaigns",
                              number: provider.data.length.toString(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CampaignDetailed(
                              title: "Active Campaigns",
                              number: provider.activeCampaigns.length.toString(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CampaignDetailed(
                              title: "Total referrals",
                              number: provider.totalReferrals.toString(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      "Active Campaigns",
                      style:
                      TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),

                    /// Active campaigns
                    provider.activeCampaigns.isEmpty
                        ? const Text("No active campaigns")
                        : isMobile
                        ? ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.activeCampaigns.length,
                      itemBuilder: (context, index) {
                        final data = provider.activeCampaigns[index];
                        return MobileCampaignCard(data: data);
                      },
                    )
                        : BuildCustomTable(data: provider.activeCampaigns),
                    const SizedBox(height: 20),

                    /// Toggle inactive
                    InkWell(
                      onTap: () async {
                        provider.setTogglingInactive(true);
                        await Future.delayed(const Duration(milliseconds: 500));
                        await provider.updateInactive();
                        provider.setTogglingInactive(false);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 45,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFCFCFCF)),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Center(
                          child: provider.isTogglingInactive
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2),
                          )
                              : Text(
                            "${provider.showInactive ? "Hide" : "View"} ${provider.inactiveCampaigns.length} inactive campaigns",
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// Inactive campaigns
                    provider.showInactive
                        ? isMobile
                        ? ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.inactiveCampaigns.length,
                      itemBuilder: (context, index) {
                        final data = provider.inactiveCampaigns[index];
                        return MobileCampaignCard(data: data);
                      },
                    )
                        : BuildCustomTable(data: provider.inactiveCampaigns)
                        : const SizedBox(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
