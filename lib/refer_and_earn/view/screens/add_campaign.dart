import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../../controller/service/campaign_service.dart';
import '../mobile/add_campaign_mobile.dart';
import '../widgets/custom_button.dart';
import '../widgets/reward_type_dropdown.dart';
import '../widgets/text_field_column.dart';
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
    final provider = Provider.of<ReferralProvider>(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 650) {
          // Mobile layout
          return AddCampaignMobile();
        } else {
          // Desktop / Tablet layout
          return SingleChildScrollView(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text("Create New Campaign", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
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
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: RewardTypeDropdown(
                                selectedValue: provider.rewardType,
                                onChanged: (value) {
                                  if (value != null) {
                                    provider.updateRewardType(value);
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
                            onChanged: (val) {
                              if (val != null) {
                                provider.updateCampaignExpiry(val);
                              }
                            },
                          ),
                          title: const Text("Set Campaign Expiry"),
                        ),
                        // Campaign Expiry Screen
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
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Flexible(
                              child: !provider.isLoading
                                  ? CustomButton(
                                      value: "Save",
                                      color: ColorsClass.primary,
                                      onTap: provider.isSaving
                                          ? () {}
                                          : () async {
                                              provider.setIsSaving(true);
                                              await CampaignService.validateAndSaveCampaign(
                                                isUpdate: false,
                                                provider: provider,
                                                context: context,
                                                campaignNameText: _campaignNameController.text,
                                                customerRewardText: _customerRewardController.text,
                                                referralRewardText: _referralRewardController.text,
                                                minPurchaseText: _minPurchaseController.text,
                                              );
                                              provider.setIsSaving(false);
                                              _clearForm(provider);
                                            },
                                    )
                                  : Container(
                                      height: 50,
                                      width: 200,
                                      decoration: BoxDecoration(color: ColorsClass.primary, borderRadius: BorderRadius.all(Radius.circular(6))),
                                      child: const Center(child: CircularProgressIndicator(color: ColorsClass.white)),
                                    ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: CustomButton(value: "Cancel", color: Colors.grey, onTap: () => _clearForm(provider)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 100),
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
  }
}
