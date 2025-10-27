class ReferredRestaurantsModel {
  int? id;
  String? restaurantId;
  String? referringRestaurantId;
  String? name;
  String? mobile;
  String? email;
  String? referredBy;
  int? claimed;

  ReferredRestaurantsModel({
    this.restaurantId,
    this.referringRestaurantId,
    this.name,
    this.mobile,
    this.email,
    this.referredBy,
    this.claimed,
    this.id,
  });

  factory ReferredRestaurantsModel.fromJson(Map<String, dynamic> json) {
    return ReferredRestaurantsModel(
      id: json['id'],
      restaurantId: json['Restaurant_id'],
      referringRestaurantId: json['ReferringRestaurantId'],
      name: json['Name'],
      mobile: json['Mobile'],
      email: json['Email'],
      referredBy: json['ReferredBy'],
      claimed: json['IsClaimed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Restaurant_Id': restaurantId,
      'ReferringRestaurantId': referringRestaurantId,
      'Name': name,
      'Mobile': mobile,
      'Email': email,
      'ReferredBy': referredBy,
      'Claimed': claimed,
    };
  }
}
