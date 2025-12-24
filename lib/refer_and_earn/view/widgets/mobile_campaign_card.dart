import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../../controller/service/campaign_service.dart';
import '../../model/campaign_model.dart';
import '../mobile/add_campaign_mobile.dart';
import 'custom_toast.dart';

/// Campaign Layout
class MobileCampaignCardMobileAllCampaign extends StatelessWidget {
  final CampaignModel data;

  const MobileCampaignCardMobileAllCampaign({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final campaignModel = CampaignModel(
      campaignId: data.campaignId,
      campaignName: data.campaignName,
      customerReward: data.customerReward,
      referrerReward: data.referrerReward,
      minPurchase: data.minPurchase,
      expiryEnableInt: data.expiryEnableInt,
      expiryType: data.expiryType,
      fixedPeriodType: data.fixedPeriodType,
      endDate: data.endDate,

      notifyCustomerInt: data.notifyCustomerInt,
      rewardType: data.rewardType,
      shopId: data.shopId,
      statusInt: data.statusInt,
      expiryEnableBool: data.expiryEnableBool,
      notifyCustomerBool: data.notifyCustomerBool,
      statusStr: data.statusStr,
    );

    const gap = SizedBox(height: 8);
    final activeCount = Provider.of<ReferralProvider>(context).activeCampaigns.length;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      data.campaignName ?? "Name",
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Consumer<ReferralProvider>(
                    builder: (context, value, child) {
                      return value.loadingId == data.campaignId
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Switch(
                              value: (data.statusStr == "1"),
                              onChanged: (val) {
                                if (val && (activeCount) >= 1) {
                                  CustomeToast.showError("Only 1 campaign active at a time");
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
                ],
              ),
              const Divider(color: Colors.grey, thickness: 1),

              gap,
              Text(
                "Reward Type: ${data.rewardType}",
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              gap,
              Text(
                "Friend's Reward: ${data.customerReward}",
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              gap,
              Text(
                "Your Reward: ${data.referrerReward}",
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              gap,
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      data.expiryEnableBool == false
                          ? "Validity: No Expiry"
                          : (data.expiryType == "After Friend's First Order")
                          ? "Validity: Expires After Friend's First Order"
                          : "Validity: ${DateFormat('dd-MM-yyyy hh:mm:ss a').format(DateTime.tryParse(data.endDate ?? "") ?? DateTime.now())}",

                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => AddCampaignMobile(campaign: campaignModel)));
                        },
                        child: SizedBox(height: 36, width: 36, child: SvgPicture.asset("assets/svg/mobile_edit.svg", color: ColorsClass.primary)),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () async {
                          await Provider.of<ReferralProvider>(context, listen: false).deleteCampaign(data.campaignId, data.shopId);
                        },
                        child: SizedBox(height: 30, width: 30, child: SvgPicture.asset("assets/svg/mobile_delete.svg")),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
