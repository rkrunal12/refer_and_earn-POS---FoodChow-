import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../model/campaign_model.dart';
import '../../model/cashback_model.dart';
import '../../model/fetch_data_model.dart';
import '../../model/referral_row_data.dart';
import '../../model/referred_restrauant_model.dart';
import '../../view/widgets/common_widgets.dart';

class ReferralProvider with ChangeNotifier {
  /// ********************************* restraurent referral screen **************************///
  List<ReferralRowData> referrals = [];

  void addReferral() {
    referrals.add(ReferralRowData());
    notifyListeners();
  }

  void removeReferral(int index) {
    referrals.removeAt(index);
    notifyListeners();
  }
  void clearList(){
    referrals = [];
    notifyListeners();
  }
  void disposeAll(){
    for(var data in referrals){
      data.dispose();
    }
  }

  /// ********************************* Main screen **************************///
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  void setSelectedIndex(int value) {
    _selectedIndex = value;
    notifyListeners();
  }

  /// ********************************* Campaign API Data **************************///
  String baseUrl = "https://api.foodchow.com/api/Refer_and_earn";
  bool _isLoading = false;
  String? _error;
  int? _loadingId;
  List<Data> _data = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get loadingId => _loadingId;
  List<Data> get data => _data;


  List<Data> get activeCampaigns =>
      _data.where((c) => c.status == true).toList();

  List<Data> get inactiveCampaigns =>
      _data.where((c) => c.status != true).toList();

  int get totalReferrals =>
      _data.fold(0, (sum, c) => sum + (c.referrerReward ?? 0));


  Future<void> fetchData(bool isUpdating) async {
    if (!isUpdating) _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse("$baseUrl/AllCampaign"));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> jsonData = decoded["data"] ?? [];

        _data = jsonData
            .whereType<Map<String, dynamic>>()
            .map((item) => Data.fromJson(item))
            .toList();
      } else {
        _error = "Failed with status code ${response.statusCode}";
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<String> addCampaign(CampaignModel campaign) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/AddCampaign"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(campaign.toAddJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        await fetchData(false);
        return decoded["message"] ?? "Success";
      } else {
        return "Failed with ${response.statusCode} → ${response.body}";
      }

    } catch (e) {
      return e.toString();
    } finally {
      notifyListeners();
    }
  }
  Future<String> updateCampaign(CampaignModel campaign, bool isStatus) async {
    if (isStatus) _loadingId = campaign.campaignId;

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/UpdateCampaign"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(campaign.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        await fetchData(true);
        return decoded["message"] ?? "Success";
      } else {
        return "Failed with ${response.statusCode} => ${response.body}";
      }
    } catch (e) {
      return e.toString();
    } finally {
      _loadingId = null;
      notifyListeners();
    }
  }
  Future<String> deleteCampaign(int? campaignID) async {
    if (campaignID == null) {
      return "Campaign ID cannot be null";
    }

    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/DeleteCampaign"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'campaign_id': campaignID}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        await fetchData(true); // refresh data after deletion
        String message = decoded["message"] ?? "Deleted successfully";
        return message;
      } else {
        final errorMsg = "Failed with ${response.statusCode} => ${response.body}";
        return errorMsg;
      }
    } catch (e, stackTrace) {
      return "Error: $e";
    } finally {
      _loadingId = null;
      notifyListeners();
    }
  }




  /// ********************************* Cashback Api Data **************************///
  CashbackModel? _allCashback;
  bool _isCashbackGetLoading = false;
  bool _isCashbackAddLoading = false;
  String? _cashbackError;

  bool get isCashbackGetLoading => _isCashbackGetLoading;
  bool get isCashbackAddLoading => _isCashbackAddLoading;
  String? get cashbackError => _cashbackError;
  CashbackModel? get allCashback => _allCashback;

  /// Fetch cashback
  Future<void> fetchCashbackData(bool isAdd) async {
    if (isAdd) _isCashbackGetLoading = true;
    _cashbackError = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse("$baseUrl/AllCashback"));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // Validate API structure
        if (decoded["data"] != null &&
            decoded["data"] is List &&
            decoded["data"].isNotEmpty) {
          // Take first item
          final cashbackJson = decoded["data"][0];
          _allCashback = CashbackModel.fromJson(cashbackJson);

          // Sync provider helpers
          _isEnables = _allCashback!.cashbackEnable == 1;
          _rewardCashbackType = _allCashback!.cashbackType ?? "Flat";
          _percentageDiscount = _rewardCashbackType == "Discount"
              ? (_allCashback!.cashbackValue?.toDouble() ?? 0)
              : 0;
          _fixedDiscount = _rewardCashbackType == "Flat"
              ? (_allCashback!.cashbackValue?.toDouble() ?? 0)
              : 0;
        } else {
          _allCashback = null;
          debugPrint("No cashback data available from API.");
        }
      } else {
        _cashbackError = "Failed to fetch data (Code: ${response.statusCode})";
        debugPrint(_cashbackError);
      }
    } catch (e) {
      _cashbackError = "Error: $e";
      debugPrint(_cashbackError);
    } finally {
      _isCashbackGetLoading = false;
      notifyListeners();
    }
  }
  Future<String> saveCashback(CashbackModel model) async {
    _isCashbackAddLoading = true;
    notifyListeners();

    try {
      final isUpdate = model.cashbackId != null;
      final url = isUpdate ? "$baseUrl/UpdateCashback" : "$baseUrl/AddCashback";

      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(model.toAddJson()),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final decode = jsonDecode(response.body);
        await fetchCashbackData(false);
        return decode["message"] ?? "Success";
      } else {
        return "Failed with ${response.statusCode} → ${response.body}";

      }
    } catch (e) {
      return e.toString();
    } finally {
      _isCashbackAddLoading = false;
      notifyListeners();
    }
  }


  /// ********************************* Referral Api Data **************************///
  bool _isReferralLoading = false;
  String? _referralError;
  List<ReferredRestaurantsModel> _referralList = [];

  bool get isReferralLoading => _isReferralLoading;
  String? get referralError => _referralError;
  List<ReferredRestaurantsModel> get referralList => _referralList;

  List<ReferredRestaurantsModel> get activeRefer =>
      _referralList.where((c) => c.claimed == true).toList();

  List<ReferredRestaurantsModel> get inactiveRefer =>
      _referralList.where((c) => c.claimed != true).toList();

  Future<void> fetchRestaurantReferralData(bool isUpdate) async {
    if(!isUpdate)  _isReferralLoading = true;
    _referralError = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(
          "https://api.foodchow.com/api/Restaurant_Refer_Earn/GetReferredRestaurants",
        ),
      );
      if (response.statusCode == 200) {
        final decode = jsonDecode(response.body);
        if (decode["data"] != null) {
          _referralList = (decode["data"] as List)
              .map((jsonItem) => ReferredRestaurantsModel.fromJson(jsonItem))
              .toList();
        } else {
          _referralList = [];
        }
      } else {
        _referralError =
            "Failed with ${response.statusCode} -> ${response.body}";
      }
    } catch (e) {
      _referralError = e.toString();
    } finally {
      _isReferralLoading = false;
      notifyListeners();
    }
  }

  Future<String> addRestaurantReferralData(ReferredRestaurantsModel model) async {
    final response = await http.post(
      Uri.parse(
        "https://api.foodchow.com/api/Restaurant_Refer_Earn/AddReferredRestaurants",
      ),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(model.toJson()),
    );

    try {
      if (response.statusCode == 200) {
        final decode = jsonDecode(response.body);
        await fetchRestaurantReferralData(true);
        return decode["message"];
      } else {

        return "Failed with code ${response.statusCode} -> ${response.body}";

      }
    } on Exception catch (e) {
      return e.toString();
    }
  }

  Future<String> deleteRestaurantReferralData(int? restauranId) async {
    notifyListeners();
    final response = await http.delete(
      Uri.parse(
        "https://api.foodchow.com/api/Restaurant_Refer_Earn/DeleteReferredRestaurant/$restauranId",
      ),
    );

    try {
      if (response.statusCode == 204) {
        await fetchRestaurantReferralData(true);
        return "Delete Success";
      } else {

         return "Failed with code ${response.statusCode} -> ${response.body}";

      }
    } on Exception catch (e) {
      return e.toString();
    }finally{
      notifyListeners();
    }
  }

  /// ********************************* Campaign Details **************************///

  bool _showInactive = false;
  bool _isTogglingInactive = false;
  bool get isTogglingInactive => _isTogglingInactive;
  bool get showInactive => _showInactive;
  String rewardType = "Flat";
  bool campaignExpiry = false;
  String campaignType = "Fixed Period";
  String expiryOption = "Set Specific End Date & Time";
  DateTime? expiryDate;
  bool notifyCustomers = false;
  bool isSaving = false;

  void setTogglingInactive(bool select){
    _isTogglingInactive = select;
    notifyListeners();
  }

  Future<void> updateInactive() async {
    _showInactive = !_showInactive;
    notifyListeners();
  }

  void updateRewardType(String value) {
    rewardType = value;
    notifyListeners();
  }

  void updateCampaignExpiry(bool value) {
    campaignExpiry = value;
    notifyListeners();
  }

  void updateCampaignType(String value) {
    campaignType = value;
    notifyListeners();
  }

  void updateExpiryOption(String value) {
    expiryOption = value;
    notifyListeners();
  }

  void updateExpiryDate(DateTime value) {
    expiryDate = value;
    notifyListeners();
  }

  void updateNotifyCustomers(bool value) {
    notifyCustomers = value;
    notifyListeners();
  }

  void setIsSaving(bool value) {
    isSaving = value;
    notifyListeners();
  }

  /// ********************************* Cashback Details **************************///
  bool _isEnables = false;

  double _percentageDiscount = 0;
  double _fixedDiscount = 0;
  String _rewardCashbackType = "Flat";

  void setIsEnables(bool value) {
    _isEnables = value;
    notifyListeners();
  }

  void setPercentageDiscount(double value) {
    _percentageDiscount = value;
    _rewardCashbackType = "Percentage";
    notifyListeners();
  }

  void setFixedDiscount(double value) {
    _fixedDiscount = value;
    _rewardCashbackType = "Flat";
    notifyListeners();
  }

  void setRewardType(String value) {
    _rewardCashbackType = value;
    notifyListeners();
  }

  double get fixedDiscount => _fixedDiscount;
  double get percentageDiscount => _percentageDiscount;
  bool get isEnables => _isEnables;
  String get rewardCashbackType => _rewardCashbackType;
}
