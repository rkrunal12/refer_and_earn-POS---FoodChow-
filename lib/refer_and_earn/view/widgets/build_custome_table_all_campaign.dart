import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controller/provider/refer_provider.dart';
import '../../controller/service/campaign_service.dart';
import '../../model/campaign_model.dart';
import 'custom_toast.dart';
import 'update_campaign.dart';

/// Build campaign DataTable (desktop/tablet)
class BuildCustomTableAllCampaign extends StatelessWidget {
  final List<CampaignModel> data;

  const BuildCustomTableAllCampaign({super.key, required this.data});

  void buildDialogeBoxUpdateCampaign(BuildContext context, CampaignModel campaignData) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Update Campaign"),
              InkWell(onTap: () => Navigator.pop(context), child: const Icon(Icons.close)),
            ],
          ),
          content: UpdateCampaign(data: campaignData),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = Provider.of<ReferralProvider>(context).activeCampaigns.length;
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
                    headingRowColor: MaterialStateProperty.all(Color(0x550AA89E)),
                    border: TableBorder.all(color: Colors.grey.shade300, width: 1),
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
                        endDate: campaign.endDate,

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
                          DataCell(Text("${campaign.customerReward}${campaign.rewardType == "Percentage" ? "%" : ""}")),
                          DataCell(Text("${campaign.referrerReward}${campaign.rewardType == "Percentage" ? "%" : ""}")),
                          DataCell(
                            Text(
                              campaign.expiryEnableBool == false
                                  ? "No Expiry"
                                  : (campaign.expiryType == "After Friend's First Order")
                                  ? "Expires After Friend's First Order"
                                  : "End: ${DateFormat('dd-MM-yyyy hh:mm:ss a').format(DateTime.tryParse(campaign.endDate ?? "") ?? DateTime.now())}",
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.teal),
                                  onPressed: () {
                                    buildDialogeBoxUpdateCampaign(context, campaignModel);
                                  },
                                ),
                                Consumer<ReferralProvider>(
                                  builder: (context, provider, child) {
                                    return provider.loadingId == campaign.campaignId
                                        ? const CircularProgressIndicator()
                                        : Switch.adaptive(
                                            value: campaignModel.statusStr == "1",
                                            onChanged: provider.loadingId != null
                                                ? null
                                                : (val) {
                                                    if (val && (activeCount >= 1)) {
                                                      CustomeToast.showError("Only 1 campaign active at a time");
                                                    } else if (DateTime.now().isAfter(DateTime.parse(campaignModel.endDate!))) {
                                                      CustomeToast.showError("Campaign is expired");
                                                    } else {
                                                      CampaignService.updateCampaigns(
                                                        CampaignModel(
                                                          campaignId: campaignModel.campaignId,
                                                          shopId: campaignModel.shopId,
                                                          campaignName: campaignModel.campaignName,
                                                          rewardType: campaignModel.rewardType,
                                                          customerReward: campaignModel.customerReward,
                                                          referrerReward: campaignModel.referrerReward,
                                                          expiryEnableInt: campaignModel.expiryEnableBool! ? 1 : 0,
                                                          minPurchase: campaignModel.minPurchase,
                                                          expiryType: campaignModel.expiryType,
                                                          fixedPeriodType: campaignModel.fixedPeriodType,
                                                          endDate: campaignModel.endDate,
                                                          notifyCustomerInt: campaignModel.notifyCustomerBool! ? 1 : 0,
                                                          statusInt: val ? 1 : 0,
                                                        ),
                                                        context,
                                                        true,
                                                      );
                                                    }
                                                  },
                                          );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: SizedBox(
                                              width: 300,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.delete_outline, color: Colors.teal, size: 48),
                                                  const SizedBox(height: 16),
                                                  Text("Delete Campaign", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    "Are you sure you want to delete this campaign?",
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                                                  ),
                                                  const SizedBox(height: 24),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: OutlinedButton(
                                                          style: OutlinedButton.styleFrom(
                                                            side: const BorderSide(color: Colors.teal),
                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                          ),
                                                          onPressed: () => Navigator.pop(context),
                                                          child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.teal)),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 16),
                                                      Expanded(
                                                        child: ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.red,
                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                          ),
                                                          onPressed: () async {
                                                            await Provider.of<ReferralProvider>(
                                                              context,
                                                              listen: false,
                                                            ).deleteCampaign(campaign.campaignId, campaign.shopId);
                                                            Navigator.pop(context);
                                                          },
                                                          child: Text("Delete", style: GoogleFonts.poppins(color: Colors.white)),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
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
