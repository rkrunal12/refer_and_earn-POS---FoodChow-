import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:refer_and_earn/refer_and_earn/view/screens/campaign_expiry_screen.dart';
import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../../controller/service/campaign_service.dart';
import '../../model/campaign_model.dart';
import 'common_widgets.dart';

/// Update campaign screen
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

  @override
  void initState() {
    super.initState();
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
    // _dateController = TextEditingController(
    //   text: DateFormat('dd-MM-yyyy HH:mm').format(
    //     DateFormat(
    //       "yyyy-MM-dd HH:mm:ss",
    //     ).parse(widget.data.endDate ?? DateTime.now().toString()),
    //   ),
    // );

    // Safely update provider after layout is complete
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final provider = context.read<ReferralProvider>();
      provider
        ..updateRewardType(widget.data.rewardType ?? "Flat")
        ..updateCampaignExpiry(widget.data.expiryEnable == 1)
        ..updateCampaignType(widget.data.expiryType ?? "Fixed Period")
        ..updateExpiryOption(
          widget.data.fixedPeriodType ?? "Set Specific End Date & Time",
        )
        ..updateExpiryDate(
          DateFormat(
            "yyyy-MM-dd HH:mm:ss",
          ).parse(widget.data.endDate ?? DateTime.now().toString()),
        )
        ..updateNotifyCustomers(widget.data.notifyCustomer == 1)
        ..setIsSaving(false);
    });
  }

  @override
  void dispose() {
    _campaignNameController.dispose();
    _customerRewardController.dispose();
    _referralRewardController.dispose();
    _minPurchaseController.dispose();
    // _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReferralProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          child: SizedBox(
            width: 600,
            child: Card(
              color: ColorsClass.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    /// 🏷 Campaign Name + Reward Type
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
                              top: 23,
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

                    /// 💰 Reward Fields
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

                    /// 💵 Minimum Purchase
                    TextFieldColumn(
                      hint: "Enter Minimum Purchase",
                      label: "Minimum Purchase (Optional)*",
                      controller: _minPurchaseController,
                      type: TextInputType.number,
                    ),

                    const SizedBox(height: 16),

                    /// ⏰ Expiry Toggle
                    ListTile(
                      leading: Checkbox(
                        value: provider.campaignExpiry,
                        onChanged: (value) =>
                            provider.updateCampaignExpiry(value ?? false),
                      ),
                      title: const Text("Set Campaign Expiry"),
                    ),

                    /// 📅 Expiry Details
                    if (provider.campaignExpiry)
                      CampaignExpiryScreen(
                        isMobile: false,
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
                                ..updateExpiryDate(
                                  selectedDate ?? DateTime.now(),
                                )
                                ..updateNotifyCustomers(notifyCustomers);
                            },
                      ),

                    const SizedBox(height: 24),

                    /// 💾 Save Button
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
                                    minPurchaseText:
                                        _minPurchaseController.text,
                                    status: widget.data.status == 1 ? "1" : "0",
                                    shopId: widget.data.shopId,
                                    campaignId: widget.data.campaignId,
                                  );

                              if (!mounted) return;
                              provider.setIsSaving(false);

                              if (result) {
                                Navigator.pop(context);
                              }
                            },
                      child: provider.isSaving
                          ? const SizedBox(
                              height: 40,
                              width: 40,
                              child: CircularProgressIndicator(strokeWidth: 2),
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
          ),
        );
      },
    );
  }
}
