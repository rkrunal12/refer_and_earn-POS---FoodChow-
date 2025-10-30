import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final isMobile = screenWidth <= 650;

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

        if (provider.error != null && provider.data.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${provider.error}",
                    style: GoogleFonts.poppins(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchData(false),
                    child: const Text("Retry"),
                  ),
                ],
              ),
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
                  if (provider.isLoading && provider.data.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  const CampaignInfoHeadersAllCampaign(),
                  const SizedBox(height: 20),

                  /// Active campaigns title
                  Text(
                    "Active Campaigns",
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),

                  /// Active campaigns
                  if (provider.activeCampaigns.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "No active campaigns",
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    )
                  else
                    isMobile
                        ? Column(
                            children: provider.activeCampaigns
                                .map(
                                  (data) => MobileCampaignCardMobileAllCampaign(
                                    data: data,
                                  ),
                                )
                                .toList(),
                          )
                        : BuildCustomTableAllCampaign(
                            data: provider.activeCampaigns,
                          ),

                  const SizedBox(height: 20),

                  /// Toggle inactive campaigns button - only show if there are inactive campaigns
                  if (provider.inactiveCampaigns.isNotEmpty)
                    const ShowInactiveCampaignsAllCampaign(),

                  /// Inactive campaigns
                  if (provider.showInactive &&
                      provider.inactiveCampaigns.isNotEmpty)
                    isMobile
                        ? Column(
                            children: provider.inactiveCampaigns
                                .map(
                                  (data) => MobileCampaignCardMobileAllCampaign(
                                    data: data,
                                  ),
                                )
                                .toList(),
                          )
                        : BuildCustomTableAllCampaign(
                            data: provider.inactiveCampaigns,
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
