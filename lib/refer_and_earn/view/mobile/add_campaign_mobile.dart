import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../../controller/service/campaign_service.dart';
import '../../model/campaign_model.dart';
import '../screens/campaign_expiry_screen.dart';
import '../widgets/custom_button.dart';
import '../widgets/mobile_app_baar.dart';
import '../widgets/reward_type_dropdown.dart';
import '../widgets/text_field_column.dart';

class AddCampaignMobile extends StatefulWidget {
  final CampaignModel? campaign;

  const AddCampaignMobile({super.key, this.campaign});

  @override
  State<AddCampaignMobile> createState() => _AddCampaignMobileState();
}

class _AddCampaignMobileState extends State<AddCampaignMobile> {
  late final TextEditingController _campaignNameController;
  late final TextEditingController _customerRewardController;
  late final TextEditingController _referralRewardController;
  late final TextEditingController _minPurchaseController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _campaignNameController = TextEditingController(text: widget.campaign?.campaignName ?? '');
    _customerRewardController = TextEditingController(text: widget.campaign?.customerReward?.toString() ?? '');
    _referralRewardController = TextEditingController(text: widget.campaign?.referrerReward?.toString() ?? '');
    _minPurchaseController = TextEditingController(text: widget.campaign?.minPurchase?.toString() ?? '');

    final provider = Provider.of<ReferralProvider>(context, listen: false);

    if (widget.campaign != null) {
      provider
        ..campaignExpiry = widget.campaign!.expiryEnableBool ?? false
        ..campaignType = widget.campaign!.expiryType ?? "Fixed Period"
        ..expiryOption = widget.campaign!.fixedPeriodType ?? "Set Specific End Date & Time"
        ..expiryDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(widget.campaign!.endDate ?? DateTime.now().toString())
        ..notifyCustomers = widget.campaign!.notifyCustomerBool ?? false ? true : false
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const MobileAppBar(title: "Refer and Earn"),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFieldColumn(
                    hint: "Enter campaign name",
                    label: "Campaign Name*",
                    controller: _campaignNameController,
                    type: TextInputType.text,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return "Campaign name is required";
                      return null;
                    },
                  ),
                  Consumer<ReferralProvider>(
                    builder: (context, provider, _) {
                      return RewardTypeDropdown(
                        selectedValue: provider.rewardType,
                        onChanged: (value) {
                          if (value != null) provider.updateRewardType(value);
                          if (value == "Percentage") {
                            if (_customerRewardController.text.length > 2) {
                              _customerRewardController.text = _customerRewardController.text.substring(0, 2);
                            }
                            if (_referralRewardController.text.length > 2) {
                              _referralRewardController.text = _referralRewardController.text.substring(0, 2);
                            }
                          }
                        },
                      );
                    },
                  ),
                  Consumer<ReferralProvider>(
                    builder: (context, provider, _) {
                      return TextFieldColumn(
                        hint: "Enter Customer Reward",
                        label: "New Customer Reward (Friend)*",
                        controller: _customerRewardController,
                        suffixText: provider.rewardType == "Percentage" ? "%" : null,
                        maxLength: provider.rewardType == "Percentage" ? 2 : null,
                        type: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return "Reward is required";
                          if (int.tryParse(val.trim()) == null) return "Enter valid number";
                          return null;
                        },
                      );
                    },
                  ),
                  Consumer<ReferralProvider>(
                    builder: (context, provider, _) {
                      return TextFieldColumn(
                        hint: "Enter Referral Reward",
                        label: "Referral Reward (You)*",
                        controller: _referralRewardController,
                        maxLength: provider.rewardType == "Percentage" ? 2 : null,
                        type: TextInputType.number,
                        suffixText: provider.rewardType == "Percentage" ? "%" : null,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return "Reward is required";
                          if (int.tryParse(val.trim()) == null) return "Enter valid number";
                          return null;
                        },
                      );
                    },
                  ),
                  TextFieldColumn(
                    hint: "Enter Minimum Purchase",
                    label: "Minimum Purchase (Optional)*",
                    controller: _minPurchaseController,
                    type: TextInputType.number,
                    maxLength: 7,
                    validator: (val) {
                      if (val != null && val.trim().isNotEmpty && int.tryParse(val.trim()) == null) {
                        return "Enter valid number";
                      }
                      return null;
                    },
                  ),

                  Consumer<ReferralProvider>(
                    builder: (context, provider, _) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          children: [
                            Checkbox(
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

                  Consumer<ReferralProvider>(
                    builder: (context, provider, _) {
                      if (!provider.campaignExpiry) return const SizedBox.shrink();
                      return CampaignExpiryScreen(
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


                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Consumer<ReferralProvider>(
        builder: (context, provider, _) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomButton(
              value: widget.campaign == null ? "Save" : "Update",
              color: ColorsClass.primary,
              onTap: provider.isSaving
                  ? () {}
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        final data = await CampaignService.validateAndSaveCampaign(
                          isUpdate: widget.campaign != null,
                          provider: provider,
                          context: context,
                          campaignNameText: _campaignNameController.text,
                          customerRewardText: _customerRewardController.text,
                          referralRewardText: _referralRewardController.text,
                          minPurchaseText: _minPurchaseController.text,
                          campaignId: widget.campaign?.campaignId,
                          shopId: widget.campaign?.shopId,
                          status: widget.campaign?.statusStr,
                        );
                        if (data) {
                          _clearForm(provider);
                        }
                      }
                    },
            ),
          );
        },
      ),
    );
  }
}
