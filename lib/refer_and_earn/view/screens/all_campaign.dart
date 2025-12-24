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
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final smallScreen = screenWidth <= 650;

    return Consumer<ReferralProvider>(
      builder: (context, provider, _) {
        // Show loading state
        if (provider.isLoading && provider.data.isEmpty) {
          return const Center(
            child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()),
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

                  Text("Active Campaigns", style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),

                  /// Active campaigns
                  if (provider.activeCampaigns.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text("No active campaigns", style: GoogleFonts.poppins(color: Colors.grey)),
                    )
                  else
                    smallScreen
                        ? Column(children: provider.activeCampaigns.map((data) => MobileCampaignCardMobileAllCampaign(data: data)).toList())
                        : BuildCustomTableAllCampaign(data: provider.activeCampaigns),

                  const SizedBox(height: 20),

                  if (provider.inactiveCampaigns.isNotEmpty) const ShowInactiveCampaignsAllCampaign(),

                  if (provider.showInactive && provider.inactiveCampaigns.isNotEmpty)
                    smallScreen
                        ? Column(children: provider.inactiveCampaigns.map((data) => MobileCampaignCardMobileAllCampaign(data: data)).toList())
                        : BuildCustomTableAllCampaign(data: provider.inactiveCampaigns),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ShowInactiveCampaignsAllCampaign extends StatelessWidget {
  const ShowInactiveCampaignsAllCampaign({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReferralProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            InkWell(
              onTap: () async {
                provider.setTogglingInactive(true);
                if (provider.inactiveCampaigns.length >= 10) {
                  await Future.delayed(const Duration(milliseconds: 500));
                }
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
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(
                          "${provider.showInactive ? "Hide" : "View"} ${provider.inactiveCampaigns.length} inactive campaign${provider.inactiveCampaigns.length == 1 ? '' : 's'}",
                          style: GoogleFonts.poppins(fontSize: 15),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}
