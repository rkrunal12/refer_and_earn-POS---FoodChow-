import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../../controller/service/campaign_service.dart';
import '../mobile/add_campaign_mobile.dart';
import '../../../reponsive.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
        if (Responsive.isMobile(context)) {
          return AddCampaignMobile();
        } else {
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
                                  suffixText: provider.rewardType == "Percentage" ? "%" : null,
                                  hint: "Enter Customer Reward",
                                  label: "New Customer Reward (Friend)*",
                                  controller: _customerRewardController,
                                  maxLength: provider.rewardType == "Flat" ? 6 : 2,
                                  onChanged: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      log("index ${value[0]}");
                                    }
                                  },
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
                                  suffixText: provider.rewardType == "Percentage" ? "%" : null,
                                  hint: "Enter Referral Reward",
                                  label: "Referral Reward (You)*",
                                  controller: _referralRewardController,
                                  maxLength: provider.rewardType == "Flat" ? 6 : 2,
                                  onChanged: (value) {
                                    if (value != null && value.isNotEmpty) {}
                                  },
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
                          // Minimum Purchase
                          TextFieldColumn(
                            hint: "Enter Minimum Purchase",
                            label: "Minimum Purchase (Optional)*",
                            controller: _minPurchaseController,
                            maxLength: 7,
                            type: TextInputType.number,
                            validator: (val) {
                              if (val != null && val.trim().isNotEmpty) {
                                if (int.tryParse(val.trim()) == null) return "Enter valid number";
                              }
                              return null;
                            },
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
                                                if (_formKey.currentState!.validate()) {
                                                  provider.setIsSaving(true);
                                                  final data = await CampaignService.validateAndSaveCampaign(
                                                    isUpdate: false,
                                                    provider: provider,
                                                    context: context,
                                                    campaignNameText: _campaignNameController.text,
                                                    customerRewardText: _customerRewardController.text,
                                                    referralRewardText: _referralRewardController.text,
                                                    minPurchaseText: _minPurchaseController.text,
                                                  );
                                                  provider.setIsSaving(false);
                                                  if (data) {
                                                    _clearForm(provider);
                                                  }
                                                }
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
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
