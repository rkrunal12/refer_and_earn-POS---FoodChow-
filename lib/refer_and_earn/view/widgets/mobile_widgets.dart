import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../../controller/service/campaign_service.dart';
import '../../model/campaign_model.dart';
import '../../model/referred_restrauant_model.dart';
import '../mobile/add_campaign_mobile.dart';
import 'common_widget.dart';

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
      endDate:
          "${data.endDateFetch?.year ?? DateTime.now().year}-"
          "${(data.endDateFetch?.month ?? DateTime.now().month).toString().padLeft(2, '0')}-"
          "${(data.endDateFetch?.day ?? DateTime.now().day).toString().padLeft(2, '0')} "
          "${(data.endDateFetch?.hour ?? DateTime.now().hour).toString().padLeft(2, '0')}:"
          "${(data.endDateFetch?.minute ?? DateTime.now().minute).toString().padLeft(2, '0')}:"
          "${(data.endDateFetch?.second ?? DateTime.now().second).toString().padLeft(2, '0')}",
      notifyCustomerInt: data.notifyCustomerInt,
      rewardType: data.rewardType,
      shopId: data.shopId,
      statusInt: data.statusInt,
      expiryEnableBool: data.expiryEnableBool,
      notifyCustomerBool: data.notifyCustomerBool,
      statusStr: data.statusStr,
    );

    const gap = SizedBox(height: 8);

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
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Consumer<ReferralProvider>(
                    builder: (context, value, child) {
                      return value.loadingId == data.campaignId
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Switch(
                              value: (data.statusStr == "1"),
                              onChanged: (val) {
                                CampaignService.updateCampaigns(
                                  CampaignModel(
                                    campaignId: campaignModel.campaignId,
                                    shopId: campaignModel.shopId,
                                    campaignName: campaignModel.campaignName,
                                    rewardType: campaignModel.rewardType,
                                    customerReward:
                                        campaignModel.customerReward,
                                    referrerReward:
                                        campaignModel.referrerReward,
                                    expiryEnableInt:
                                        campaignModel.expiryEnableBool! ? 1 : 0,
                                    minPurchase: campaignModel.minPurchase,
                                    expiryType: campaignModel.expiryType,
                                    fixedPeriodType:
                                        campaignModel.fixedPeriodType,
                                    endDate: campaignModel.endDate,
                                    notifyCustomerInt:
                                        campaignModel.notifyCustomerBool!
                                        ? 1
                                        : 0,
                                    statusInt: val ? 1 : 0,
                                  ),
                                  context,
                                  true,
                                );
                              },
                            );
                    },
                  ),
                ],
              ),
              const Divider(color: Colors.grey, thickness: 1),

              gap,
              CustomText(
                text: "Reward Type: ${data.rewardType}",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              gap,
              CustomText(
                text: "Friend's Reward: ${data.customerReward}",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              gap,
              CustomText(
                text: "Your Reward: ${data.referrerReward}",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              gap,
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: CustomText(
                      text: data.expiryEnableBool == false
                          ? "Validity: No Expiry"
                          : (data.expiryType == "After Friend's First Order")
                          ? "Validity: Expires After Friend's First Order"
                          : "Validity: ${DateFormat('dd-MM-yyyy hh:mm:ss a').format(DateTime(data.endDateFetch?.year ?? 1970, data.endDateFetch?.month ?? 1, data.endDateFetch?.day ?? 1, data.endDateFetch?.hour ?? 0, data.endDateFetch?.minute ?? 0, data.endDateFetch?.second ?? 0))}",

                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddCampaignMobile(
                                campaign: campaignModel,
                              ),
                            ),
                          );
                        },
                        child: SizedBox(
                          height: 36,
                          width: 36,
                          child: SvgPicture.asset(
                            "assets/svg/mobile_edit.svg",
                            color: ColorsClass.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () async {
                          await Provider.of<ReferralProvider>(
                            context,
                            listen: false,
                          ).deleteCampaign(data.campaignId, data.shopId);
                        },
                        child: SizedBox(
                          height: 30,
                          width: 30,
                          child: SvgPicture.asset(
                            "assets/svg/mobile_delete.svg",
                          ),
                        ),
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

/// Custom appBar
class MobileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const MobileAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600),
      ),
      backgroundColor: ColorsClass.white,
      actions: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/images/user.png", height: 24, width: 24),
            const SizedBox(width: 10),
            Text("Admin", style: GoogleFonts.poppins(fontSize: 17)),
            const SizedBox(width: 10),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Mobile RestRestaurant Referral Table
class CustomTableRestaurantMobileReferral extends StatelessWidget {
  final List<ReferredRestaurantsModel>? list;

  const CustomTableRestaurantMobileReferral({
    super.key,
    required this.list,
  });

  @override
  Widget build(BuildContext context) {
    if (list == null || list!.isEmpty) {
      return const Center(child: Text("No referrals available"));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: list!.length,
      itemBuilder: (context, index) {
        final data = list![index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          data.name ?? "-",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildActions(
                        context,
                        data.id,
                        data.restaurantId,
                        data.claimed,
                      ),
                    ],
                  ),

                  const Divider(thickness: 1, color: Colors.grey),

                  _buildRow("Mobile", data.mobile ?? "-"),
                  _buildRow("Email", data.email ?? "-"),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            "$title:",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatus(int? data) {
    final isCompleted = data == 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0x808DBD90) : const Color(0x80D87E7E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF007521)
              : const Color(0xFFFC0005),
          width: 2,
        ),
      ),
      child: Text(
        isCompleted ? "Completed" : "Pending",
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          fontSize: 11,
          color: ColorsClass.blackColor,
        ),
      ),
    );
  }

  Widget _buildActions(
    BuildContext context,
    int? id,
    String? restaurantId,
    int? claimed,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatus(claimed),
        const SizedBox(width: 8),
        Consumer<ReferralProvider>(
          builder: (context, provider, _) {
            return InkWell(
              onTap: () async {
                await Provider.of<ReferralProvider>(
                  context,
                  listen: false,
                ).deleteRestaurantReferralData(restaurantId, id);
              },
              child: SizedBox(
                height: 25,
                width: 25,
                child: SvgPicture.asset("assets/svg/mobile_delete.svg"),
              ),
            );
          },
        ),
      ],
    );
  }
}
