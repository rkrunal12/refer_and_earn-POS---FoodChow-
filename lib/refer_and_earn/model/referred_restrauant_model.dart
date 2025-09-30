class ReferredRestaurantsModel {
  int? restaurantId;
  int? referringRestaurantId;
  String? name;
  String? mobile;
  String? email;
  String? referredBy;
  bool? claimed;

  ReferredRestaurantsModel({
    this.restaurantId,
    this.referringRestaurantId,
    this.name,
    this.mobile,
    this.email,
    this.referredBy,
    this.claimed,
  });

  // Factory constructor to create a model from JSON
  factory ReferredRestaurantsModel.fromJson(Map<String, dynamic> json) {
    return ReferredRestaurantsModel(
      restaurantId: json['Restaurant_id'],
      referringRestaurantId: json['ReferringRestaurantId'],
      name: json['Name'],
      mobile: json['Mobile'],
      email: json['Email'],
      referredBy: json['ReferredBy'],
      claimed: json['Claimed'],
    );
  }

  // Method to convert the model to JSON
  Map<String, dynamic> toJson() {
    return {
      'ReferringRestaurantId': referringRestaurantId,
      'Name': name,
      'Mobile': mobile,
      'Email': email,
      'ReferredBy': referredBy,
      'Claimed': claimed,
    };
  }
  Map<String, dynamic> toUpdateJson() {
    return {
      'RestaurantId' : restaurantId,
      'ReferringRestaurantId': referringRestaurantId,
      'Name': name,
      'Mobile': mobile,
      'Email': email,
      'ReferredBy': referredBy,
      'Claimed': claimed,
    };
  }
}
