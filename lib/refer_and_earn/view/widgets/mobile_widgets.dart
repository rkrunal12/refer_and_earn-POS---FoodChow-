import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../../controller/service/campaign_service.dart';
import '../../model/campaign_model.dart';
import '../../model/fetch_data_model.dart';
import '../../model/referral_row_data.dart';
import '../../model/referred_restrauant_model.dart';
import '../mobile/add_campaign_mobile.dart';
import 'cashback_widgets.dart';
import 'common_widgets.dart';

/// Campaign Layout
class MobileCampaignCard extends StatelessWidget {
  final Data data;

  const MobileCampaignCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final campaignModel = CampaignModel(
      campaignId: data.campaignId,
      campaignName: data.campaignName,
      customerReward: data.customerReward,
      referrerReward: data.referrerReward,
      minPurchase: data.minPurchase,
      expiryEnable: data.expiryEnable,
      expiryType: data.expiryType,
      fixedPeriodType: data.fixedPeriodType,
      endDate: data.endDate!.toIso8601String(),
      notifyCustomer: data.notifyCustomer,
      rewardType: data.rewardType,
      shopId: data.shopId,
      status: data.status,
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
              /// Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      data.campaignName ?? "Name",
                      style: const TextStyle(
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
                              value: data.status ?? false,
                              onChanged: (val) {
                                CampaignService.updateCampaigns(
                                  campaignModel..status = val,
                                  true,
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
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              gap,
              CustomText(
                text: "Friend's Reward: ${data.customerReward}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              gap,
              CustomText(
                text: "Your Reward: ${data.referrerReward}",
                style: const TextStyle(
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
                      text:
                          "Validity : ${data.expiryEnable! ? (data.expiryType == "Fixed Period" ? DateFormat('yyyy-mm-dd hh:mm:ss a').format(data.endDate!) : "After Friend's First Order") : "No Expiry"}",
                      style: TextStyle(
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
                                isMobile: true,
                              ),
                            ),
                          );
                        },
                        child: SizedBox(
                          height: 36,
                          child: Image.asset(
                            "assets/images/refer_and_earn/mobile_edit.png",
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () async {
                          final deleteData =
                              await Provider.of<ReferralProvider>(
                                context,
                                listen: false,
                              ).deleteCampaign(data.campaignId);
                          CustomSnackBar.show(deleteData, true);
                        },
                        child: SizedBox(
                          height: 30,
                          child: Image.asset(
                            "assets/images/refer_and_earn/mobile_delete.png",
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

/// Foodchow cash toggle
class MobileToggleCard extends StatelessWidget {
  final bool isEnable;
  final ValueChanged<bool> onChanged;

  const MobileToggleCard({
    super.key,
    required this.isEnable,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text(
        "Authorised FoodChow Cash",
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      subtitle: const Text(
        "Enable this to start accepting FoodChow Cash",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.grey,
        ),
      ),
      trailing: Switch(value: isEnable, onChanged: onChanged),
    );
  }
}

/// Mobile cashback rules with slider
class MobileRulesCard extends StatelessWidget {
  final TabController tabController;

  const MobileRulesCard({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              "Cash Back Rules",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            ),
          ),
          TabBar(
            controller: tabController,
            isScrollable: false,
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.black,
            indicatorColor: Colors.teal,
            labelPadding: const EdgeInsets.only(left: 5),
            tabs: const [
              Tab(text: "Percentage Discount"),
              Tab(text: "Fixed Amount"),
            ],
          ),
          SizedBox(
            height: 100,
            child: Consumer<ReferralProvider>(
              builder: (context, data, _) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final newIndex = data.rewardCashbackType == "Flat" ? 1 : 0;
                  if (tabController.index != newIndex &&
                      !tabController.indexIsChanging &&
                      newIndex < tabController.length) {
                    tabController.index = newIndex;
                  }
                });

                return TabBarView(
                  controller: tabController,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: CashbackSlider(
                        currentValue: data.percentageDiscount,
                        maxValue: 50,
                        labelPrefix: "Allow up to",
                        onChanged: data.setPercentageDiscount,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: CashbackSlider(
                        currentValue: data.fixedDiscount,
                        maxValue: 500,
                        labelPrefix: "Allow fixed amount of",
                        onChanged: data.setFixedDiscount,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
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
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
      backgroundColor: ColorsClass.white,
      actions: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/images/refer_and_earn/user.png",
              height: 24,
              width: 24,
            ),
            const SizedBox(width: 10),
            const Text("Admin", style: TextStyle(fontSize: 17)),
            const SizedBox(width: 10),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Mobile RestRestaurant
class CustomTableRestaurantMobile extends StatelessWidget {
  final List<ReferredRestaurantsModel>? list;

  const CustomTableRestaurantMobile({super.key, required this.list});

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
                  /// Header: Name + Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          data.name ?? "-",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildActions(context, data),
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
            style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatus(ReferredRestaurantsModel data) {
    final isCompleted = data.claimed ?? false;
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
        style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 10),
      ),
    );
  }

  Widget _buildActions(BuildContext context, ReferredRestaurantsModel data) {
    return Row(

      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatus(data),
        const SizedBox(width: 8),
        Consumer<ReferralProvider>(
          builder: (context, provider, _) {
            return provider.loadingId == data.restaurantId
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : InkWell(
                    onTap: () async {
                      final deleteData = await Provider.of<ReferralProvider>(
                        context,
                        listen: false,
                      ).deleteRestaurantReferralData(data.restaurantId);
                      CustomSnackBar.show(deleteData, true);
                    },
                    child: SizedBox(
                      height: 25,
                      width: 25,
                      child: Image.asset("assets/images/refer_and_earn/mobile_delete.png"),
                    ),
                  );
          },
        ),
      ],
    );
  }
}

/// referral row mobile
class ReferralRowMobile extends StatelessWidget {
  final ReferralRowData referral;
  final VoidCallback onSend;
  final VoidCallback onDelete;

  const ReferralRowMobile({
    super.key,
    required this.referral,
    required this.onSend,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFieldColumn(
          hint: "Enter Restaurant Name",
          label: "Restaurant Name",
          controller: referral.nameController,
          type: TextInputType.name,
        ),
        TextFieldColumn(
          mobile: true,
          isPhone: true,
          hint: "Enter Mobile No.",
          label: "Mobile No.",
          controller: referral.mobileController,
          type: TextInputType.phone,
          onIsoCodeChanged: (code) {
            referral.isoCode = code ?? "IN";
          },
        ),
        TextFieldColumn(
          hint: "Enter Email",
          label: "Email",
          controller: referral.emailController,
          type: TextInputType.emailAddress,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    height: 50,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Color(0xFFFC0005)),
                      borderRadius: BorderRadiusGeometry.all(
                        Radius.circular(6),
                      ),
                    ),
                    child: Center(
                      child: CustomText(
                        text: "Delete",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color(0xFFFC0005),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    onSend();
                  },
                  child: CustomButton(
                    value: "Send",
                    color: ColorsClass.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

/// mobile header
class MobileHeader extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final String mobileTitle;
  const MobileHeader({
    super.key,
    required this.title,
    required this.onTap,
    required this.mobileTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
      ), // adjusted for mobile
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: title, // use the passed title
            style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 36,
              width: 130,
              decoration: BoxDecoration(
                color: ColorsClass.primary,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Text(
                  mobileTitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ColorsClass.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



/// Content container card
class ContentContainerMobile extends StatelessWidget {
  final Widget leading;
  final String title;

  const ContentContainerMobile({
    super.key,
    required this.leading,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: ColorsClass.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: ListTile(
        leading: SizedBox(height: 30, width: 30, child: leading),
        title: CustomText(
          text: title,
          style: const TextStyle(
            fontFamily: "Poppins",
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
