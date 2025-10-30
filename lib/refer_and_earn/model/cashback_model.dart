class CashbackModel {
  int? cashbackId;
  String? shopId;
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

}
