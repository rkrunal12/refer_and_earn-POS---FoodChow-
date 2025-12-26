import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:refer_and_earn/refer_and_earn/view/screens/campaign_expiry_screen.dart';
import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../../controller/service/campaign_service.dart';
import '../../model/campaign_model.dart';
import 'custom_button.dart';
import 'reward_type_dropdown.dart';
import 'text_field_column.dart';

class UpdateCampaign extends StatefulWidget {
  const UpdateCampaign({super.key, required this.data});
  final CampaignModel data;

  @override
  State<UpdateCampaign> createState() => _UpdateCampaignState();
}

class _UpdateCampaignState extends State<UpdateCampaign> {
  late final TextEditingController _campaignNameController;
  late final TextEditingController _customerRewardController;
  late final TextEditingController _referralRewardController;
  late final TextEditingController _minPurchaseController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _campaignNameController = TextEditingController(text: widget.data.campaignName ?? '');
    _customerRewardController = TextEditingController(text: widget.data.customerReward?.toString() ?? '');
    _referralRewardController = TextEditingController(text: widget.data.referrerReward?.toString() ?? '');
    _minPurchaseController = TextEditingController(text: widget.data.minPurchase?.toString() ?? '');

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final provider = context.read<ReferralProvider>();
      provider
        ..updateRewardType(widget.data.rewardType ?? "Flat")
        ..updateCampaignExpiry(widget.data.expiryEnableBool ?? true)
        ..updateCampaignType(widget.data.expiryType ?? "Fixed Period")
        ..updateExpiryOption(widget.data.fixedPeriodType ?? "Set Specific End Date & Time")
        ..updateExpiryDate(DateTime.tryParse(widget.data.endDate ?? "") ?? DateTime.now())
        ..updateNotifyCustomers(widget.data.notifyCustomerBool ?? false)
        ..setIsSaving(false);
    });
  }

  @override
  void dispose() {
    _campaignNameController.dispose();
    _customerRewardController.dispose();
    _referralRewardController.dispose();
    _minPurchaseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReferralProvider>(context, listen: true);

    return SingleChildScrollView(
      child: SizedBox(
        width: 600,
        child: Card(
          color: ColorsClass.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFieldColumn(
                          hint: "Enter campaign name",
                          label: "Campaign Name*",
                          controller: _campaignNameController,
                          type: TextInputType.text,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return "Campaign name is required";
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: RewardTypeDropdown(
                          selectedValue: provider.rewardType,
                          onChanged: (value) {
                            if (value != null) {
                              provider.updateRewardType(value);
                              if (value == "Percentage") {
                                if (_customerRewardController.text.length > 2) {
                                  _customerRewardController.text = _customerRewardController.text.substring(0, 2);
                                }
                                if (_referralRewardController.text.length > 2) {
                                  _referralRewardController.text = _referralRewardController.text.substring(0, 2);
                                }
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextFieldColumn(
                          hint: "Enter Customer Reward",
                          label: "New Customer Reward (Friend)*",
                          controller: _customerRewardController,
                          suffixText: provider.rewardType == "Percentage" ? "%" : null,
                          maxLength: provider.rewardType == "Percentage" ? 2 : 6,
                          type: TextInputType.number,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return "Reward is required";
                            if (int.tryParse(val.trim()) == null) return "Enter valid number";
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFieldColumn(
                          hint: "Enter Referral Reward",
                          label: "Referral Reward (You)*",
                          controller: _referralRewardController,
                          suffixText: provider.rewardType == "Percentage" ? "%" : null,
                          maxLength: provider.rewardType == "Percentage" ? 2 : 6,
                          type: TextInputType.number,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return "Reward is required";
                            if (int.tryParse(val.trim()) == null) return "Enter valid number";
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

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

                  const SizedBox(height: 16),

                  ListTile(
                    leading: Checkbox(value: provider.campaignExpiry, onChanged: (value) => provider.updateCampaignExpiry(value ?? false)),
                    title: const Text("Set Campaign Expiry"),
                  ),

                  if (provider.campaignExpiry)
                    CampaignExpiryScreen(
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
                    ),

                  const SizedBox(height: 24),

                  provider.isSaving
                      ? const SizedBox(height: 40, width: 40, child: CircularProgressIndicator(strokeWidth: 2))
                      : CustomButton(
                          value: "Save",
                          color: ColorsClass.primary,
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              provider.setIsSaving(true);
                              final result = await CampaignService.validateAndSaveCampaign(
                                isUpdate: true,
                                provider: provider,
                                context: context,
                                campaignNameText: _campaignNameController.text,
                                customerRewardText: _customerRewardController.text,
                                referralRewardText: _referralRewardController.text,
                                minPurchaseText: _minPurchaseController.text,
                                status: widget.data.statusStr,
                                shopId: widget.data.shopId,
                                campaignId: widget.data.campaignId,
                              );

                              if (!mounted) return;
                              provider.setIsSaving(false);

                              if (result) {
                                Navigator.pop(context);
                              }
                            }
                          },
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
