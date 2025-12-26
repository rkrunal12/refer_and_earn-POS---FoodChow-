class CashbackModel {
  int? cashbackId;
  String? shopId;
  int? cashbackEnable;
  String? cashbackType;
  int? cashbackValue;
  int? minimumOrderAmount;
  String? termsAndConditions;

  CashbackModel({
    this.cashbackId,
    this.shopId,
    this.cashbackEnable,
    this.cashbackType,
    this.cashbackValue,
    this.minimumOrderAmount,
    this.termsAndConditions,
  });

  factory CashbackModel.fromJson(Map<String, dynamic> json) {
    return CashbackModel(
      cashbackId: json['cashback_id'],
      shopId: json['shop_id'],
      cashbackEnable: json['cashback_enable'],
      cashbackType: json['cashback_type'],
      cashbackValue: json['cashback_value'],  
      minimumOrderAmount: json['minimum_order_amount'],
      termsAndConditions: json['term_and_condition'],
    ); 
  }

  Map<String, dynamic> toJson() {
    return {
      'cashback_id': cashbackId,
      'shop_id': shopId,
      'cashback_enable': cashbackEnable,
      'cashback_type': cashbackType,
      'cashback_value': cashbackValue,
      'minimum_amount': minimumOrderAmount,
      'term_and_condition': termsAndConditions,
    };
  }
}
