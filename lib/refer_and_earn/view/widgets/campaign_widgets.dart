import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:refer_and_earn/refer_and_earn/view/widgets/update_campaign.dart';
import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../../controller/service/campaign_service.dart';
import '../../model/campaign_model.dart';

/// Campaign detailed card for summary
class CampaignDetailedCampaignInfo extends StatelessWidget {
  final String title;
  final String number;

  const CampaignDetailedCampaignInfo({
    super.key,
    required this.title,
    required this.number,
  });

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
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                number,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 29,
                  color: ColorsClass.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Campaign info headers
class CampaignInfoHeadersAllCampaign extends StatelessWidget {
  const CampaignInfoHeadersAllCampaign({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReferralProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 700;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: isSmallScreen
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CampaignDetailedCampaignInfo(
                  title: "Total Campaigns",
                  number: provider.data.length.toString(),
                ),
                CampaignDetailedCampaignInfo(
                  title: "Active Campaigns",
                  number: provider.activeCampaigns.length.toString(),
                ),
                CampaignDetailedCampaignInfo(
                  title: "Total referrals",
                  number: provider.totalReferrals.toString(),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: CampaignDetailedCampaignInfo(
                    title: "Total Campaigns",
                    number: provider.data.length.toString(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CampaignDetailedCampaignInfo(
                    title: "Active Campaigns",
                    number: provider.activeCampaigns.length.toString(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CampaignDetailedCampaignInfo(
                    title: "Total referrals",
                    number: provider.totalReferrals.toString(),
                  ),
                ),
              ],
            ),
    );
  }
}

/// Build campaign DataTable (desktop/tablet)
class BuildCustomTableAllCampaign extends StatelessWidget {
  final List<CampaignModel> data;

  const BuildCustomTableAllCampaign({super.key, required this.data});

  void buildDialogeBoxUpdateCampaign(
    BuildContext context,
    CampaignModel campaignData,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Update Campaign"),
              InkWell(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close),
              ),
            ],
          ),
          content: UpdateCampaign(data: campaignData),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return data.isEmpty
        ? SizedBox()
        : LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      Color(0x550AA89E),
                    ),
                    border: TableBorder.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                    columnSpacing: 20,
                    columns: const [
                      DataColumn(label: Text("Campaign Name")),
                      DataColumn(label: Text("Reward Type")),
                      DataColumn(label: Text("Friend's Reward")),
                      DataColumn(label: Text("Your Reward")),
                      DataColumn(label: Text("Validity")),
                      DataColumn(label: Text("Action")),
                    ],
                    rows: data.map((campaign) {
                      final campaignModel = CampaignModel(
                        campaignId: campaign.campaignId,
                        campaignName: campaign.campaignName,
                        customerReward: campaign.customerReward,
                        referrerReward: campaign.referrerReward,
                        minPurchase: campaign.minPurchase,
                        expiryEnableInt: campaign.expiryEnableInt,
                        expiryType: campaign.expiryType,
                        fixedPeriodType: campaign.fixedPeriodType,
                        endDate:
                            "${campaign.endDateFetch?.year ?? DateTime.now().year}-"
                            "${(campaign.endDateFetch?.month ?? DateTime.now().month).toString().padLeft(2, '0')}-"
                            "${(campaign.endDateFetch?.day ?? DateTime.now().day).toString().padLeft(2, '0')} "
                            "${(campaign.endDateFetch?.hour ?? DateTime.now().hour).toString().padLeft(2, '0')}:"
                            "${(campaign.endDateFetch?.minute ?? DateTime.now().minute).toString().padLeft(2, '0')}:"
                            "${(campaign.endDateFetch?.second ?? DateTime.now().second).toString().padLeft(2, '0')}",
                        notifyCustomerInt: campaign.notifyCustomerInt,
                        rewardType: campaign.rewardType,
                        shopId: campaign.shopId?.toString(),
                        statusInt: campaign.statusInt,
                        statusStr: campaign.statusStr,
                        expiryEnableBool: campaign.expiryEnableBool,
                        notifyCustomerBool: campaign.notifyCustomerBool,
                      );

                      return DataRow(
                        cells: [
                          DataCell(Text(campaign.campaignName ?? "")),
                          DataCell(Text(campaign.rewardType ?? "")),
                          DataCell(Text("${campaign.customerReward}%")),
                          DataCell(Text("${campaign.referrerReward}%")),
                          DataCell(
                            Text(
                              campaign.expiryEnableBool == false
                                  ? "No Expiry"
                                  : (campaign.expiryType ==
                                        "After Friend's First Order")
                                  ? "Expires After Friend's First Order"
                                  : "End: ${DateFormat('dd-MM-yyyy hh:mm:ss a').format(DateTime(campaign.endDateFetch?.year ?? 1970, campaign.endDateFetch?.month ?? 1, campaign.endDateFetch?.day ?? 1, campaign.endDateFetch?.hour ?? 0, campaign.endDateFetch?.minute ?? 0, campaign.endDateFetch?.second ?? 0))}",
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.teal,
                                  ),
                                  onPressed: () {
                                    buildDialogeBoxUpdateCampaign(
                                      context,
                                      campaignModel,
                                    );
                                  },
                                ),
                                Consumer<ReferralProvider>(
                                  builder: (context, provider, child) {
                                    return provider.loadingId ==
                                            campaign.campaignId
                                        ? const CircularProgressIndicator()
                                        : Switch.adaptive(
                                            value:
                                                campaignModel.statusStr == "1",
                                            onChanged: (val) {
                                              CampaignService.updateCampaigns(
                                                CampaignModel(
                                                  campaignId:
                                                      campaignModel.campaignId,
                                                  shopId: campaignModel.shopId,
                                                  campaignName: campaignModel
                                                      .campaignName,
                                                  rewardType:
                                                      campaignModel.rewardType,
                                                  customerReward: campaignModel
                                                      .customerReward,
                                                  referrerReward: campaignModel
                                                      .referrerReward,
                                                  expiryEnableInt:
                                                      campaignModel
                                                          .expiryEnableBool!
                                                      ? 1
                                                      : 0,
                                                  minPurchase:
                                                      campaignModel.minPurchase,
                                                  expiryType:
                                                      campaignModel.expiryType,
                                                  fixedPeriodType: campaignModel
                                                      .fixedPeriodType,
                                                  endDate:
                                                      campaignModel.endDate,
                                                  notifyCustomerInt:
                                                      campaignModel
                                                          .notifyCustomerBool!
                                                      ? 1
                                                      : 0,
                                                  statusInt: val ? 1 : 0,
                                                ),
                                                context,
                                                false,
                                              );
                                            },
                                          );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    await Provider.of<ReferralProvider>(
                                      context,
                                      listen: false,
                                    ).deleteCampaign(
                                      campaign.campaignId,
                                      campaign.shopId,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          );
  }
}
