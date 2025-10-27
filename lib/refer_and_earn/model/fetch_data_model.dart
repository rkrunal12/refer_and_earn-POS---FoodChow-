class Data {
  int? campaignId;
  String? shopId;
  String? campaignName;
  String? rewardType;
  int? customerReward;
  int? referrerReward;
  int? minPurchase;
  bool? expiryEnable;
  String? expiryType;
  String? fixedPeriodType;
  EndDate? endDate;
  bool? notifyCustomer;
  String? status;
  EndDate? createdAt;
  dynamic updatedAt;

  Data({
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
    this.createdAt,
    this.updatedAt,
  });

  Data.fromJson(Map<String, dynamic> json) {
    campaignId = json['campaign_id'];
    shopId = json['shop_id'];
    campaignName = json['campaign_name'];
    rewardType = json['reward_type'];
    customerReward = json['customer_reward'];
    referrerReward = json['referrer_reward'];
    minPurchase = json['min_purchase'];
    expiryEnable = json['expiry_enable'];
    expiryType = json['expiry_type'];
    fixedPeriodType = json['fixed_period_type'];
    endDate = json['end_date'] != null
        ? EndDate.fromJson(json['end_date'])
        : null;
    notifyCustomer = json['notify_customer'];
    status = json['status'];
    createdAt = json['created_at'] != null
        ? EndDate.fromJson(json['created_at'])
        : null;
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['campaign_id'] = campaignId;
    data['shop_id'] = shopId;
    data['campaign_name'] = campaignName;
    data['reward_type'] = rewardType;
    data['customer_reward'] = customerReward;
    data['referrer_reward'] = referrerReward;
    data['min_purchase'] = minPurchase;
    data['expiry_enable'] = expiryEnable;
    data['expiry_type'] = expiryType;
    data['fixed_period_type'] = fixedPeriodType;
    if (endDate != null) {
      data['end_date'] = endDate!.toJson();
    }
    data['notify_customer'] = notifyCustomer;
    data['status'] = status;
    if (createdAt != null) {
      data['created_at'] = createdAt!.toJson();
    }
    data['updated_at'] = updatedAt;
    return data;
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
