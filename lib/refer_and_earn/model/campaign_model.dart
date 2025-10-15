class CampaignModel {
  int? campaignId;
  String? shopId;
  String? campaignName;
  String? rewardType;
  int? customerReward;
  int? referrerReward;
  int? minPurchase;
  int? expiryEnable;
  String? expiryType;
  String? fixedPeriodType;
  String? endDate;
  int? notifyCustomer;
  int? status;

  CampaignModel({
    this.campaignId,
    this.shopId,
    this.campaignName,
    this.rewardType,
    this.customerReward,
    this.referrerReward,
    this.minPurchase,
    this.expiryEnable,
    this.expiryType,
    this.fixedPeriodType,
    this.endDate,
    this.notifyCustomer,
    this.status,
  });

  CampaignModel.add({
    this.shopId,
    this.campaignName,
    this.rewardType,
    this.customerReward,
    this.referrerReward,
    this.minPurchase,
    this.expiryEnable,
    this.expiryType,
    this.fixedPeriodType,
    this.endDate,
    this.notifyCustomer,
    this.status,
  });

  CampaignModel.update({
    required this.campaignId,
    required this.shopId,
    this.campaignName,
    this.rewardType,
    this.customerReward,
    this.referrerReward,
    this.minPurchase,
    this.expiryEnable,
    this.expiryType,
    this.fixedPeriodType,
    this.endDate,
    this.notifyCustomer,
    this.status,
  });

  /// From JSON
  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      campaignId: json['campaign_id'],
      shopId: json['shop_id'],
      campaignName: json['campaign_name'],
      rewardType: json['reward_type'],
      customerReward: json['customer_reward'],
      referrerReward: json['referrer_reward'],
      minPurchase: json['min_purchase'],
      expiryEnable: json['expiry_enable'],
      expiryType: json['expiry_type'],
      fixedPeriodType: json['fixed_period_type'],
      endDate: json['end_date'],
      notifyCustomer: json['notify_customer'] ?? false,
      status: json['status'],
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'campaign_id': campaignId,
      'shop_id': shopId,
      'campaign_name': campaignName,
      'reward_type': rewardType,
      'customer_reward': customerReward,
      'referrer_reward': referrerReward,
      'min_purchase': minPurchase,
      'expiry_enable': expiryEnable,
      'expiry_type': expiryType,
      'fixed_period_type': fixedPeriodType,
      'end_date': endDate,
      'notify_customer': notifyCustomer,
      'status': status,
    };
  }

  Map<String, dynamic> toAddJson() {
    return {
      'shop_id': shopId,
      'campaign_name': campaignName,
      'reward_type': rewardType,
      'customer_reward': customerReward,
      'referrer_reward': referrerReward,
      'min_purchase': minPurchase,
      'expiry_enable': expiryEnable,
      'expiry_type': expiryType,
      'fixed_period_type': fixedPeriodType,
      'end_date': endDate,
      'notify_customer': notifyCustomer,
      'status': status,
    };
  }
}
