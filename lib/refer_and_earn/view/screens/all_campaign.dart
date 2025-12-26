import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controller/provider/refer_provider.dart';
import '../../controller/service/campaign_service.dart';
import '../../model/campaign_model.dart';
import '../widgets/build_custome_table_all_campaign.dart';

import '../widgets/custom_toast.dart';
import '../widgets/mobile_campaign_card.dart';
import '../../color_class.dart';
import '../../../reponsive.dart';

class AllCampaign extends StatefulWidget {
  const AllCampaign({super.key});

  @override
  State<AllCampaign> createState() => _AllCampaignState();
}

class _AllCampaignState extends State<AllCampaign> {
  final FocusNode _focusNode = FocusNode();

  Timer? _expiryTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<ReferralProvider>(context, listen: false);
      if (provider.data.isEmpty) {
        await provider.fetchData(false);
      }
    });
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _manageTimer(ReferralProvider provider) {
    bool shouldRun =
        provider.selectedIndex == 1 &&
        provider.activeCampaigns.isNotEmpty &&
        provider.activeCampaigns[0].expiryEnableBool == true &&
        provider.activeCampaigns[0].expiryType != "After Friend's First Order" &&
        provider.activeCampaigns[0].endDate != null;

    if (shouldRun) {
      if (_expiryTimer == null || !_expiryTimer!.isActive) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkAndExpireCampaigns(provider);
        });

        _expiryTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
          if (mounted) {
            _checkAndExpireCampaigns(provider);
          }
        });
      }
    } else {
      if (_expiryTimer != null) {
        _expiryTimer?.cancel();
        _expiryTimer = null;
      }
    }
  }

  Future<void> _checkAndExpireCampaigns(ReferralProvider provider) async {
    final now = DateTime.now();
    final List<CampaignModel> expiredCampaigns = [];
    for (CampaignModel campaign in provider.activeCampaigns) {
      if (campaign.expiryEnableBool == true) {
        if (campaign.expiryType != "After Friend's First Order") {
          if (campaign.endDate != null) {
            final expiryDate = DateTime.tryParse(campaign.endDate!);
            if (expiryDate != null && now.isAfter(expiryDate)) {
              expiredCampaigns.add(campaign);
              CustomeToast.showError("Campaign '${campaign.campaignName}' has expired");
            }
          }
        }
      }
    }

    for (var campaign in expiredCampaigns) {
      await CampaignService.updateCampaigns(
        CampaignModel(
          campaignId: campaign.campaignId,
          shopId: campaign.shopId,
          campaignName: campaign.campaignName,
          rewardType: campaign.rewardType,
          customerReward: campaign.customerReward,
          referrerReward: campaign.referrerReward,
          expiryEnableInt: campaign.expiryEnableBool! ? 1 : 0,
          minPurchase: campaign.minPurchase,
          expiryType: campaign.expiryType,
          fixedPeriodType: campaign.fixedPeriodType,
          endDate: campaign.endDate,
          notifyCustomerInt: campaign.notifyCustomerBool! ? 1 : 0,
          statusInt: 0,
        ),
        context,
        false,
        isExpired: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final smallScreen = Responsive.isMobile(context);
        final isSmallScreen = Responsive.isMobile(context);

        return Consumer<ReferralProvider>(
          builder: (context, provider, _) {
            _manageTimer(provider);

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

                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: isSmallScreen
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _CampaignDetailedCampaignInfo(title: "Total Campaigns", number: provider.data.length.toString()),
                                  _CampaignDetailedCampaignInfo(title: "Active Campaigns", number: provider.activeCampaigns.length.toString()),
                                  _CampaignDetailedCampaignInfo(title: "Total referrals", number: provider.totalReferrals.toString()),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: _CampaignDetailedCampaignInfo(title: "Total Campaigns", number: provider.data.length.toString()),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _CampaignDetailedCampaignInfo(
                                      title: "Active Campaigns",
                                      number: provider.activeCampaigns.length.toString(),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _CampaignDetailedCampaignInfo(title: "Total referrals", number: provider.totalReferrals.toString()),
                                  ),
                                ],
                              ),
                      ),
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
                        BuildCustomTableAllCampaign(data: provider.activeCampaigns),

                      const SizedBox(height: 20),

                      if (provider.inactiveCampaigns.isNotEmpty) const _ShowInactiveCampaignsAllCampaign(),

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
      },
    );
  }
}

class _ShowInactiveCampaignsAllCampaign extends StatelessWidget {
  const _ShowInactiveCampaignsAllCampaign();

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
