import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../../controller/service/campaign_service.dart';
import '../mobile/add_campaign_mobile.dart';
import '../widgets/common_widgets.dart';
import 'campaign_expiry_screen.dart';

class AddCampaign extends StatefulWidget {
  const AddCampaign({super.key});

  @override
  State<AddCampaign> createState() => _AddCampaignState();
}

class _AddCampaignState extends State<AddCampaign> {
  final TextEditingController _campaignNameController = TextEditingController();
  final TextEditingController _customerRewardController = TextEditingController();
  final TextEditingController _referralRewardController = TextEditingController();
  final TextEditingController _minPurchaseController = TextEditingController();

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
    return Consumer<ReferralProvider>(
      builder: (context, provider, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth <= 600) {
              // Mobile layout
              return AddCampaignMobile(isMobile: false,);
            } else {
              // Desktop / Tablet layout
              return SingleChildScrollView(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        "Create New Campaign",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Card(
                      color: Colors.white,
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
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
                                  child: RewardTypeDropdown(
                                    selectedValue: provider.rewardType,
                                    onChanged: (value) {
                                      if (value != null) provider.updateRewardType(value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Customer Reward + Referral Reward
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
                              leading: CustomCheckBox(
                                value: provider.campaignExpiry,
                                onChanged: (val) {
                                  if (val != null) provider.updateCampaignExpiry(val);
                                },
                              ),
                              title: const Text("Set Campaign Expiry"),
                            ),
                            // Campaign Expiry Screen
                            if (provider.campaignExpiry)
                              CampaignExpiryScreen(
                                isMobile: false,
                                onChanged: ({
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
                            const SizedBox(height: 16),
                            // Save and Cancel Buttons
                            Row(
                              children: [
                                Flexible(
                                  child: GestureDetector(
                                    onTap: provider.isSaving
                                        ? null
                                        : () async {
                                      provider.setIsSaving(true);
                                      await CampaignService.validateAndSaveCampaign(
                                        isMobile: false,
                                        isUpdate: false,
                                        provider: provider,
                                        context: context,
                                        campaignNameText: _campaignNameController.text,
                                        customerRewardText: _customerRewardController.text,
                                        referralRewardText: _referralRewardController.text,
                                        minPurchaseText: _minPurchaseController.text,
                                      );
                                      provider.setIsSaving(false);
                                    },
                                    child: CustomButton(
                                      value: "Save",
                                      color: ColorsClass.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: GestureDetector(
                                    onTap: () => _clearForm(provider),
                                    child: const CustomButton(
                                      value: "Cancel",
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 100,),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        );
      },
    );
  }
}
