import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/campaign_model.dart';
import '../../view/widgets/common_widget.dart';
import '../provider/refer_provider.dart';

class CampaignService {
  static Future<void> updateCampaigns(CampaignModel data, BuildContext context, bool isStateUpdating, {bool isExpired = false}) async {
    try {
      final provider = Provider.of<ReferralProvider>(context, listen: false);
      await provider.updateCampaign(data, isStateUpdating, isExpired: isExpired);
    } catch (e) {
      CustomeToast.showError("Error updating campaign: $e");
    }
  }

  static Future<bool> validateAndSaveCampaign({
    required bool isUpdate,
    required BuildContext context,
    required ReferralProvider provider,
    String? campaignNameText,
    String? customerRewardText,
    String? referralRewardText,
    String? minPurchaseText,
    String? status,
    String? shopId,
    int? campaignId,
  }) async {
    void showError(String msg) => CustomeToast.showError(msg);

    final campaignName = campaignNameText?.trim() ?? "";
    final customerRewardStr = customerRewardText?.trim() ?? "";
    final referralRewardStr = referralRewardText?.trim() ?? "";
    final minPurchaseStr = minPurchaseText?.trim() ?? "";

    // --- Validations ---
    if (campaignName.isEmpty) {
      showError("Campaign name is required");
      return false;
    }

    if (provider.rewardType.trim().isEmpty) {
      showError("Reward type is required");
      return false;
    }

    final customerReward = int.tryParse(customerRewardStr);
    if (customerReward == null) {
      showError("Enter customer reward as a valid number");
      return false;
    }

    final referralReward = int.tryParse(referralRewardStr);
    if (referralReward == null) {
      showError("Enter referral reward as a valid number");
      return false;
    }

    int minPurchase = 0;
    if (minPurchaseStr.isNotEmpty) {
      final parsed = int.tryParse(minPurchaseStr);
      if (parsed == null) {
        showError("Minimum purchase must be a valid number");
        return false;
      } else {
        minPurchase = parsed;
      }
    }

    if (provider.campaignExpiry) {
      if (provider.campaignType.trim().isEmpty) {
        showError("Campaign type is required");
        return false;
      }

      if (provider.campaignType == "Fixed Period") {
        if (provider.expiryOption.trim().isEmpty) {
          showError("Expiry option is required");
          return false;
        }

        if (provider.expiryOption == "Set Specific End Date & Time" && provider.expiryDate == null) {
          showError("Expiry date is required");
          return false;
        }
      }
    }

    DateTime? expiryEndDate;
    if (provider.campaignExpiry && provider.expiryDate != null) {
      expiryEndDate = provider.expiryDate;
    }

    provider.setIsSaving(true);

    try {
      if (isUpdate) {
        await CampaignService.updateCampaigns(
          CampaignModel.update(
            statusInt: status == "1" ? 1 : 0,
            shopId: shopId,
            rewardType: provider.rewardType,
            referrerReward: referralReward,
            notifyCustomerInt: provider.notifyCustomers ? 1 : 0,
            minPurchase: minPurchase,
            fixedPeriodType: provider.expiryOption,
            expiryType: provider.campaignType,
            expiryEnableInt: provider.campaignExpiry ? 1 : 0,
            endDate: expiryEndDate?.toIso8601String() ?? DateTime(1970, 1, 1).toIso8601String(),
            customerReward: customerReward,
            campaignName: campaignName,
            campaignId: campaignId,
          ),
          context,
          false,
        );
      } else {
        await CampaignService.saveCampaign(
          campaignName,
          provider.rewardType,
          customerReward,
          referralReward,
          minPurchase,
          provider.campaignExpiry,
          provider.campaignType,
          provider.expiryOption,
          expiryEndDate,
          provider.notifyCustomers,
          "1",
          context,
        );
      }
      return true;
    } catch (e) {
      showError("Something went wrong: $e");
      return false;
    } finally {
      provider.setIsSaving(false);
    }
  }

  static Future<void> saveCampaign(
    String? campaignName,
    String? rewardType,
    int? customerReward,
    int? referrerReward,
    int? minPurchase,
    bool? expiryEnable,
    String? expiryType,
    String? fixedPeriodType,
    DateTime? endDate,
    bool? notifyCustomer,
    String? status,
    BuildContext context,
  ) async {
    // Validation / defaults for expiry
    if (expiryEnable == true) {
      if (expiryType == null || expiryType.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Expiry type is required")));
        return;
      }

      if (expiryType == "Fixed Period") {
        if (fixedPeriodType == null || fixedPeriodType.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Expiry option is required")));
          return;
        }

        if (fixedPeriodType == "Set Specific End Date & Time" && endDate == null) {
          CustomeToast.showError("Expiry date is required");
          return;
        } else if (fixedPeriodType == "Based on Days") {
          endDate = DateTime.now().add(const Duration(days: 30));
        } else if (fixedPeriodType == "Based on Hours") {
          endDate = DateTime.now().add(const Duration(hours: 72));
        }
      } else {
        endDate = DateTime(9999, 12, 31, 0, 0, 0);
      }
    } else {
      expiryEnable = false;
      expiryType = "";
      fixedPeriodType = "";
      endDate = DateTime(9999, 12, 31, 0, 0, 0);
    }

    final campaign = CampaignModel.add(
      shopId: "7872",
      campaignName: campaignName,
      rewardType: rewardType,
      customerReward: customerReward,
      referrerReward: referrerReward,
      minPurchase: minPurchase,
      expiryEnableInt: expiryEnable == true ? 1 : 0,
      expiryType: expiryType,
      fixedPeriodType: fixedPeriodType,
      endDate: endDate?.toString(),
      notifyCustomerInt: notifyCustomer == true ? 1 : 0,
      statusInt: 0,
    );

    final provider = Provider.of<ReferralProvider>(context, listen: false);
    await provider.addCampaign(campaign);
  }
}
