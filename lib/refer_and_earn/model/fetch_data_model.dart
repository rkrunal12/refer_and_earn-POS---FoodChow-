class Data {
  int? campaignId;
  int? shopId;
  String? campaignName;
  String? rewardType;
  int? customerReward;
  int? referrerReward;
  int? minPurchase;
  bool? expiryEnable;
  String? expiryType;
  String? fixedPeriodType;
  DateTime? endDate;
  bool? notifyCustomer;
  bool? status;
  DateTime? createdAt;
  DateTime? updatedAt;

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

  factory Data.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse nested datetime
    DateTime? parseDateTime(Map? dateObj) {
      if (dateObj == null) return null;
      final value = dateObj['value'];
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    // Convert status to bool
    bool parseStatus(dynamic val) {
      if (val == null) return false;
      if (val is bool) return val;
      if (val is String) {
        return val.toLowerCase() == 'active' || val == '1';
      }
      if (val is num) return val == 1;
      return false;
    }

    return Data(
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
      endDate: parseDateTime(json['end_date']),
      notifyCustomer: json['notify_customer'] ?? false,
      status: parseStatus(json['status']),
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    String? formatDate(DateTime? dt) => dt?.toIso8601String();

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
      'end_date': formatDate(endDate),
      'notify_customer': notifyCustomer,
      'status': status,
      'created_at': formatDate(createdAt),
      'updated_at': formatDate(updatedAt),
    };
  }
}
