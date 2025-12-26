class ReferredRestaurantsModel {
  int? id;
  String? restaurantId;
  String? referringRestaurantId;
  String? name;
  String? mobile;
  String? email;
  int? claimed;

  ReferredRestaurantsModel({this.restaurantId, this.referringRestaurantId, this.name, this.mobile, this.email, this.claimed, this.id});

  factory ReferredRestaurantsModel.fromJson(Map<String, dynamic> json) {
    return ReferredRestaurantsModel(
      id: json['id'],
      restaurantId: json['Restaurant_id'],
      name: json['Name'],
      mobile: json['Mobile'],
      email: json['Email'],
      claimed: json['Claimed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'ReferringRestaurantId': referringRestaurantId, 'Name': name, 'Mobile': mobile, 'Email': email};
  }
}
