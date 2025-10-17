import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../../controller/service/campaign_service.dart';
import '../../model/campaign_model.dart';
import 'common_widgets.dart';

/// Update campaign
class UpdateCampaign extends StatefulWidget {
  const UpdateCampaign({super.key, required this.data});
  final CampaignModel data;

  @override
  State<UpdateCampaign> createState() => _UpdateCampaignState();
}

class _UpdateCampaignState extends State<UpdateCampaign> {
  late TextEditingController _campaignNameController;
  late TextEditingController _customerRewardController;
  late TextEditingController _referralRewardController;
  late TextEditingController _minPurchaseController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers immediately
    _campaignNameController = TextEditingController(
      text: widget.data.campaignName ?? '',
    );
    _customerRewardController = TextEditingController(
      text: widget.data.customerReward?.toString() ?? '',
    );
    _referralRewardController = TextEditingController(
      text: widget.data.referrerReward?.toString() ?? '',
    );
    _minPurchaseController = TextEditingController(
      text: widget.data.minPurchase?.toString() ?? '',
    );

    // Update provider fields safely after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ReferralProvider>();
      provider
        ..updateRewardType(widget.data.rewardType ?? "Flat")
        ..updateCampaignExpiry(widget.data.expiryEnable == true ? true : false)
        ..updateCampaignType(widget.data.expiryType ?? "Fixed Period")
        ..updateExpiryOption(
          widget.data.fixedPeriodType ?? "Set Specific End Date & Time",
        )
        ..updateExpiryDate(
          DateTime.tryParse(widget.data.endDate ?? '') ?? DateTime.now(),
        )
        ..updateNotifyCustomers(
          widget.data.notifyCustomer == true ? true : false,
        )
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
    return Consumer<ReferralProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          child: Card(
            color: ColorsClass.white,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Campaign Name + Reward Type
                  Row(
                    children: [
                      Expanded(
                        child: TextFieldColumn(
                          hint: "Enter campaign name",
                          label: "Campaign Name*",
                          controller: _campaignNameController,
                          type: TextInputType.text,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 23.0,
                            left: 16,
                            right: 16,
                          ),
                          child: DropdownButtonFormField<String>(
                            value: provider.rewardType,
                            hint: const Text("Reward Type"),
                            items: const ["Flat", "Percentage"]
                                .map(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null) provider.updateRewardType(val);
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Rewards Row
                  Row(
                    children: [
                      Expanded(
                        child: TextFieldColumn(
                          hint: "Enter Customer Reward",
                          label: "New Customer Reward (Friend)*",
                          controller: _customerRewardController,
                          type: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFieldColumn(
                          hint: "Enter Referral Reward",
                          label: "Referral Reward (You)*",
                          controller: _referralRewardController,
                          type: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Minimum Purchase
                  TextFieldColumn(
                    hint: "Enter Minimum Purchase",
                    label: "Minimum Purchase (Optional)*",
                    controller: _minPurchaseController,
                    type: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  // Campaign Expiry Checkbox
                  ListTile(
                    leading: Checkbox(
                      value: provider.campaignExpiry,
                      onChanged: (value) =>
                          provider.updateCampaignExpiry(value ?? false),
                    ),
                    title: const Text("Set Campaign Expiry"),
                  ),

                  // Campaign Type Radios
                  if (provider.campaignExpiry)
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text("Fixed Period"),
                            value: "Fixed Period",
                            groupValue: provider.campaignType,
                            onChanged: (value) => provider.updateCampaignType(
                              value ?? "Fixed Period",
                            ),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text("After Friend's First Order"),
                            value: "After Friend's First Order",
                            groupValue: provider.campaignType,
                            onChanged: (value) => provider.updateCampaignType(
                              value ?? "After Friend's First Order",
                            ),
                          ),
                        ),
                      ],
                    ),

                  // Expiry Options
                  if (provider.campaignExpiry &&
                      provider.campaignType == "Fixed Period")
                    Column(
                      children: [
                        CustomRadioListTile(
                          value: "Set Specific End Date & Time",
                          title: "Set Specific End Date & Time",
                          groupValue: provider.expiryOption,
                          onChanged: (val) {
                            provider.updateExpiryOption(val!);
                            provider.updateExpiryDate(DateTime.now());
                          },
                        ),
                        CustomRadioListTile(
                          title: "Based on Hours",
                          value: "Based on Hours",
                          groupValue: provider.expiryOption,
                          onChanged: (val) {
                            provider.updateExpiryOption(val!);
                            CustomSnackBar.showSuccess(
                              "Campaign will expire in 72 hours",
                            );
                          },
                        ),
                        CustomRadioListTile(
                          value: "Based on Days",
                          title: "Based on Days",
                          groupValue: provider.expiryOption,
                          onChanged: (val) {
                            provider.updateExpiryOption(val!);
                            CustomSnackBar.showSuccess(
                              "Campaign will expire in 30 Days",
                            );
                          },
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),

                  // Notify Customer Checkbox
                  if (provider.campaignExpiry)
                    Row(
                      children: [
                        Checkbox(
                          value: provider.notifyCustomers,
                          onChanged: (val) =>
                              provider.updateNotifyCustomers(val ?? false),
                        ),
                        const Text("Notify customers before expiry"),
                      ],
                    ),

                  const SizedBox(height: 20),

                  // Save Button
                  GestureDetector(
                    onTap: provider.isSaving
                        ? null
                        : () async {
                            provider.setIsSaving(true);
                            final result =
                                await CampaignService.validateAndSaveCampaign(
                                  isMobile: false,
                                  isUpdate: true,
                                  provider: provider,
                                  context: context,
                                  campaignNameText:
                                      _campaignNameController.text,
                                  customerRewardText:
                                      _customerRewardController.text,
                                  referralRewardText:
                                      _referralRewardController.text,
                                  minPurchaseText: _minPurchaseController.text,
                                  status: widget.data.status == 1 ? "1" : "0",
                                  shopId: widget.data.shopId,
                                  campaignId: widget.data.campaignId,
                                );
                            provider.setIsSaving(false);
                            if (result && mounted) {
                              Navigator.pop(context);
                            }
                          },
                    child: provider.isSaving
                        ? const SizedBox(
                            height: 40,
                            width: 40,
                            child: CircularProgressIndicator(),
                          )
                        : CustomButton(
                            value: "Save",
                            color: ColorsClass.primary,
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
