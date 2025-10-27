import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../../controller/service/campaign_service.dart';
import '../../model/campaign_model.dart';
import '../screens/campaign_expiry_screen.dart';
import '../widgets/common_widgets.dart';
import '../widgets/mobile_widgets.dart';

class AddCampaignMobile extends StatefulWidget {
  final CampaignModel? campaign;
  final bool isMobile;

  const AddCampaignMobile({super.key, this.campaign, required this.isMobile});

  @override
  State<AddCampaignMobile> createState() => _AddCampaignMobileState();
}

class _AddCampaignMobileState extends State<AddCampaignMobile> {
  late final TextEditingController _campaignNameController;
  late final TextEditingController _customerRewardController;
  late final TextEditingController _referralRewardController;
  late final TextEditingController _minPurchaseController;

  @override
  void initState() {
    super.initState();

    _campaignNameController = TextEditingController(
      text: widget.campaign?.campaignName ?? '',
    );
    _customerRewardController = TextEditingController(
      text: widget.campaign?.customerReward?.toString() ?? '',
    );
    _referralRewardController = TextEditingController(
      text: widget.campaign?.referrerReward?.toString() ?? '',
    );
    _minPurchaseController = TextEditingController(
      text: widget.campaign?.minPurchase?.toString() ?? '',
    );

    final provider = Provider.of<ReferralProvider>(context, listen: false);

    if (widget.campaign != null) {
      provider
        ..campaignExpiry = widget.campaign!.expiryEnable == 1 ? true : false
        ..campaignType = widget.campaign!.expiryType ?? "Fixed Period"
        ..expiryOption =
            widget.campaign!.fixedPeriodType ?? "Set Specific End Date & Time"
        ..expiryDate = parseDate(widget.campaign!.endDate)
        ..notifyCustomers = widget.campaign!.notifyCustomer == 1 ? true : false
        ..rewardType = widget.campaign!.rewardType ?? "Flat";
      debugPrint(widget.campaign!.endDate.toString());
    } else {
      _clearForm(provider);
    }
  }

  @override
  void dispose() {
    _campaignNameController.dispose();
    _customerRewardController.dispose();
    _referralRewardController.dispose();
    _minPurchaseController.dispose();
    super.dispose();
  }

  void _clearForm(ReferralProvider provider) {
    _campaignNameController.clear();
    _customerRewardController.clear();
    _referralRewardController.clear();
    _minPurchaseController.clear();

    provider
      ..rewardType = "Flat"
      ..campaignExpiry = false
      ..campaignType = "Fixed Period"
      ..expiryOption = "Set Specific End Date & Time"
      ..expiryDate = null
      ..notifyCustomers = false
      ..isSaving = false;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReferralProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.isMobile
          ? const MobileAppBar(title: "Refer and Earn")
          : null,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campaign Name
            TextFieldColumn(
              hint: "Enter campaign name",
              label: "Campaign Name*",
              controller: _campaignNameController,
              type: TextInputType.text,
            ),

            // Reward Type Dropdown wrapped in Consumer
            Consumer<ReferralProvider>(
              builder: (context, provider, _) {
                return RewardTypeDropdown(
                  selectedValue: provider.rewardType,
                  onChanged: (value) {
                    if (value != null) provider.updateRewardType(value);
                  },
                );
              },
            ),

            // Customer Reward
            TextFieldColumn(
              hint: "Enter Customer Reward",
              label: "New Customer Reward (Friend)*",
              controller: _customerRewardController,
              type: TextInputType.number,
            ),
            // Referral Reward
            TextFieldColumn(
              hint: "Enter Referral Reward",
              label: "Referral Reward (You)*",
              controller: _referralRewardController,
              type: TextInputType.number,
            ),
            // Minimum Purchase
            TextFieldColumn(
              hint: "Enter Minimum Purchase",
              label: "Minimum Purchase (Optional)*",
              controller: _minPurchaseController,
              type: TextInputType.number,
            ),

            // Campaign Expiry Checkbox wrapped in Consumer
            Consumer<ReferralProvider>(
              builder: (context, provider, _) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    children: [
                      CustomCheckBox(
                        value: provider.campaignExpiry,
                        onChanged: (val) {
                          if (val != null) provider.updateCampaignExpiry(val);
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text("Set Campaign Expiry"),
                    ],
                  ),
                );
              },
            ),

            // Campaign Expiry Screen wrapped in Consumer
            Consumer<ReferralProvider>(
              builder: (context, provider, _) {
                if (!provider.campaignExpiry) return const SizedBox.shrink();
                return CampaignExpiryScreen(
                  isMobile: widget.isMobile,
                  onChanged:
                      ({
                        required String campaignType,
                        required String expiryOption,
                        DateTime? selectedDate,
                        required bool notifyCustomers,
                        int? duration,
                      }) {
                        provider
                          ..updateCampaignType(campaignType)
                          ..updateExpiryOption(expiryOption)
                          ..updateExpiryDate(selectedDate ?? DateTime.now())
                          ..updateNotifyCustomers(notifyCustomers);
                      },
                );
              },
            ),

            const SizedBox(height: 20),

            // Save / Update Button
            GestureDetector(
              onTap: provider.isSaving
                  ? null
                  : () async {
                      final success =
                          await CampaignService.validateAndSaveCampaign(
                            isUpdate: widget.campaign != null,
                            provider: provider,
                            context: context,
                            campaignNameText: _campaignNameController.text,
                            customerRewardText: _customerRewardController.text,
                            referralRewardText: _referralRewardController.text,
                            minPurchaseText: _minPurchaseController.text,
                            campaignId: widget.campaign?.campaignId,
                            shopId: widget.campaign?.shopId,
                            status: widget.campaign?.status == 1 ? "1" : "0",
                            isMobile: widget.isMobile,
                          );

                      if (success && widget.isMobile) {
                        Navigator.pop(context);
                      }
                      _clearForm(provider);
                    },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: CustomButton(
                  value: widget.campaign == null ? "Save" : "Update",
                  color: ColorsClass.primary,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  DateTime parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return DateTime.now();
    }

    try {
      // Try standard ISO format first
      return DateTime.parse(dateString);
    } catch (_) {
      try {
        // Try common custom format: yyyy-MM-dd HH:mm:ss
        final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
        return formatter.parse(dateString);
      } catch (_) {
        try {
          // Try fallback format: yyyy/MM/dd HH:mm:ss
          final fallbackFormatter = DateFormat('yyyy/MM/dd HH:mm:ss');
          return fallbackFormatter.parse(dateString);
        } catch (_) {
          // If all fail, use current time
          debugPrint('⚠️ Invalid date format: $dateString');
          return DateTime.now();
        }
      }
    }
  }
}
