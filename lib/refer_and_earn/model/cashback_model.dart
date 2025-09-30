class CashbackModel {
  int? cashbackId;
  int? shopId;
  int? cashbackEnable;
  String? cashbackType;
  int? cashbackValue;

  CashbackModel({
    this.cashbackId,
    this.shopId,
    this.cashbackEnable,
    this.cashbackType,
    this.cashbackValue,
  });

  factory CashbackModel.fromJson(Map<String, dynamic> json) {
    return CashbackModel(
      cashbackId: json['cashback_id'],
      shopId: json['shop_id'],
      cashbackEnable: json['cashback_enable'],
      cashbackType: json['cashback_type'],
      cashbackValue: json['cashback_value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cashback_id': cashbackId,
      'shop_id': shopId,
      'cashback_enable': cashbackEnable,
      'cashback_type': cashbackType,
      'cashback_value': cashbackValue,
    };
  }

  Map<String, dynamic> toAddJson() {
    return {
      'cashback_id': cashbackId,
      'shop_id': shopId,
      'cashback_enable': cashbackEnable,
      'cashback_type': cashbackType,
      'cashback_value': cashbackValue,
    };
  }

  Map<String, dynamic> toDeleteJson() {
    return {
      'cashback_id': cashbackId,
    };
  }

  CashbackModel copyWith({
    int? cashbackId,
    int? shopId,
    int? cashbackEnable,
    String? cashbackType,
    int? cashbackValue,
  }) {
    return CashbackModel(
      cashbackId: cashbackId ?? this.cashbackId,
      shopId: shopId ?? this.shopId,
      cashbackEnable: cashbackEnable ?? this.cashbackEnable,
      cashbackType: cashbackType ?? this.cashbackType,
      cashbackValue: cashbackValue ?? this.cashbackValue,
    );
  }
}
