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
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ReferralProvider>(context, listen: false);
      provider.fetchData(false);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 550;

    return Consumer<ReferralProvider>(
      builder: (context, provider, _) {
        // Show loading state
        if (provider.isLoading && provider.data.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show error state
        if (provider.error != null && provider.data.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 50),
                const SizedBox(height: 16),
                Text(
                  "Error: ${provider.error}",
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchData(false),
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Card(
            color: Colors.white,
            margin: const EdgeInsets.all(10),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show loading indicator during refresh
                  if (provider.isLoading && provider.data.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  /// Totals row
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: isMobile
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CampaignDetailed(
                                title: "Total Campaigns",
                                number: provider.data.length.toString(),
                              ),
                              CampaignDetailed(
                                title: "Active Campaigns",
                                number: provider.activeCampaigns.length
                                    .toString(),
                              ),
                              CampaignDetailed(
                                title: "Total referrals",
                                number: provider.totalReferrals.toString(),
                              ),
                            ],
                          )
                        : Row(
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
                                  number: provider.activeCampaigns.length
                                      .toString(),
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

                  /// Active campaigns title
                  const Text(
                    "Active Campaigns",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),

                  /// Active campaigns
                  if (provider.activeCampaigns.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "No active campaigns",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    isMobile
                        ? Column(
                            children: provider.activeCampaigns
                                .map((data) => MobileCampaignCard(data: data))
                                .toList(),
                          )
                        : BuildCustomTable(data: provider.activeCampaigns),

                  const SizedBox(height: 20),

                  /// Toggle inactive campaigns button - only show if there are inactive campaigns
                  if (provider.inactiveCampaigns.isNotEmpty)
                    Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            provider.setTogglingInactive(true);
                            await Future.delayed(
                              const Duration(milliseconds: 500),
                            );
                            await provider.updateInactive();
                            provider.setTogglingInactive(false);
                          },
                          child: Container(
                            width: double.infinity,
                            height: 45,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFCFCFCF),
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Center(
                              child: provider.isTogglingInactive
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      "${provider.showInactive ? "Hide" : "View"} ${provider.inactiveCampaigns.length} inactive campaign${provider.inactiveCampaigns.length == 1 ? '' : 's'}",
                                      style: const TextStyle(fontSize: 15),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),

                  /// Inactive campaigns
                  if (provider.showInactive &&
                      provider.inactiveCampaigns.isNotEmpty)
                    isMobile
                        ? Column(
                            children: provider.inactiveCampaigns
                                .map((data) => MobileCampaignCard(data: data))
                                .toList(),
                          )
                        : BuildCustomTable(data: provider.inactiveCampaigns),

                  // Show message if no data at all
                  if (provider.data.isEmpty &&
                      !provider.isLoading &&
                      provider.error == null)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.campaign_outlined,
                            size: 60,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "No campaigns available",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
