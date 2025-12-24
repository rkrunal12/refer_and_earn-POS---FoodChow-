class CampaignModel {
  int? campaignId;
  String? shopId;
  String? campaignName;
  String? rewardType;
  int? customerReward;
  int? referrerReward;
  int? minPurchase;
  int? expiryEnableInt;
  String? expiryType;
  String? fixedPeriodType;
  String? endDate;
  int? notifyCustomerInt;
  int? statusInt;

  /// Saprate for fetch, as data is from API is in different data type
  String? statusStr;
  bool? expiryEnableBool;
  bool? notifyCustomerBool;

  CampaignModel.fetch({
    this.campaignId,
    this.shopId,
    this.campaignName,
    this.rewardType,
    this.customerReward,
    this.referrerReward,
    this.minPurchase,
    this.expiryEnableBool,
    this.expiryType,
    this.fixedPeriodType,
    this.endDate,
    this.notifyCustomerBool,
    this.statusStr,
  });

  CampaignModel({
    this.campaignId,
    this.shopId,
    this.campaignName,
    this.rewardType,
    this.customerReward,
    this.referrerReward,
    this.minPurchase,
    this.expiryEnableInt,
    this.expiryType,
    this.fixedPeriodType,
    this.endDate,
    this.notifyCustomerInt,
    this.statusInt,
    this.statusStr,
    this.expiryEnableBool,
    this.notifyCustomerBool,
  });

  CampaignModel.add({
    this.shopId,
    this.campaignName,
    this.rewardType,
    this.customerReward,
    this.referrerReward,
    this.minPurchase,
    this.expiryEnableInt,
    this.expiryType,
    this.fixedPeriodType,
    this.endDate,
    this.notifyCustomerInt,
    this.statusInt,
  });

  CampaignModel.update({
    required this.campaignId,
    required this.shopId,
    this.campaignName,
    this.rewardType,
    this.customerReward,
    this.referrerReward,
    this.minPurchase,
    this.expiryEnableInt,
    this.expiryType,
    this.fixedPeriodType,
    this.endDate,
    this.notifyCustomerInt,
    this.statusInt,
  });

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel.fetch(
      campaignId: json['campaign_id'],
      shopId: json['shop_id'],
      campaignName: json['campaign_name'],
      rewardType: json['reward_type'],
      customerReward: json['customer_reward'],
      referrerReward: json['referrer_reward'],
      minPurchase: json['min_purchase'],
      expiryEnableBool: json['expiry_enable'],
      expiryType: json['expiry_type'],
      fixedPeriodType: json['fixed_period_type'],
      endDate: json['end_date'] != null ? json['end_date']['value'] : null,
      notifyCustomerBool: json['notify_customer'] ?? false,
      statusStr: json['status'],
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'campaign_id': campaignId,
      'shop_id': shopId,
      'campaign_name': campaignName,
      'reward_type': rewardType,
      'customer_reward': customerReward,
      'referrer_reward': referrerReward,
      'min_purchase': minPurchase,
      'expiry_enable': expiryEnableInt,
      'expiry_type': expiryType,
      'fixed_period_type': fixedPeriodType,
      'end_date': endDate,
      'notify_customer': notifyCustomerInt,
      'status': statusInt,
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
      'expiry_enable': expiryEnableInt,
      'expiry_type': expiryType,
      'fixed_period_type': fixedPeriodType,
      'end_date': endDate,
      'notify_customer': notifyCustomerInt,
      'status': statusInt,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'campaign_id': campaignId,
      'shop_id': shopId,
      'campaign_name': campaignName,
      'reward_type': rewardType,
      'customer_reward': customerReward,
      'referrer_reward': referrerReward,
      'min_purchase': minPurchase,
      'expiry_enable': expiryEnableInt,
      'expiry_type': expiryType,
      'fixed_period_type': fixedPeriodType,
      'end_date': endDate,
      'notify_customer': notifyCustomerInt,
      'status': statusInt,
      'status_str': statusStr,
      'expiry_enable_bool': expiryEnableBool,
      'notify_customer_bool': notifyCustomerBool,
    };
  }
}

class EndDate {
  bool? isValidDateTime;
  int? year;
  int? month;
  int? day;
  int? hour;
  int? minute;
  int? second;
  int? millisecond;
  int? microsecond;
  bool? isNull;
  String? value;

  EndDate({
    this.isValidDateTime,
    this.year,
    this.month,
    this.day,
    this.hour,
    this.minute,
    this.second,
    this.millisecond,
    this.microsecond,
    this.isNull,
    this.value,
  });

  EndDate.fromJson(Map<String, dynamic> json) {
    isValidDateTime = json['isValidDateTime'];
    year = json['year'];
    month = json['month'];
    day = json['day'];
    hour = json['hour'];
    minute = json['minute'];
    second = json['second'];
    millisecond = json['millisecond'];
    microsecond = json['microsecond'];
    isNull = json['isNull'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isValidDateTime'] = isValidDateTime;
    data['year'] = year;
    data['month'] = month;
    data['day'] = day;
    data['hour'] = hour;
    data['minute'] = minute;
    data['second'] = second;
    data['millisecond'] = millisecond;
    data['microsecond'] = microsecond;
    data['isNull'] = isNull;
    data['value'] = value;
    return data;
  }
}
