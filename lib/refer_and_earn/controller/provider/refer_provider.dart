import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../model/campaign_model.dart';
import '../../model/cashback_model.dart';
import '../../model/fetch_data_model.dart';
import '../../model/referral_row_data.dart';
import '../../model/referred_restrauant_model.dart';

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

  void clearList() {
    referrals = [];
    notifyListeners();
  }

  void disposeAll() {
    for (var data in referrals) {
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
      _data.where((c) => c.status == "1").toList();

  List<Data> get inactiveCampaigns =>
      _data.where((c) => c.status != "1").toList();

  int get totalReferrals =>
      _data.fold(0, (sum, c) => sum + (c.referrerReward ?? 0));

  Future<void> fetchData(bool isUpdating) async {
    if (!isUpdating) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final response = await http
          .get(Uri.parse("$baseUrl/CampaignsByShop?shopId=7866"))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        if (response.body.trim().isEmpty) {
          _error = "No data received from server";
          _data = [];
          return;
        }

        try {
          final decoded = jsonDecode(response.body);
          log("API Response decoded successfully");

          // Direct access to the nested list structure
          if (decoded is Map<String, dynamic> &&
              decoded.containsKey('data') &&
              decoded['data'] is List &&
              decoded['data'].isNotEmpty &&
              decoded['data'][0] is List) {
            final List<dynamic> dataList = decoded['data'][0];
            log("Extracted ${dataList.length} campaigns from nested structure");

            final List<Data> jsonData = [];
            for (var item in dataList) {
              if (item is Map<String, dynamic>) {
                try {
                  final data = Data.fromJson(item);
                  jsonData.add(data);
                  log("✓ Successfully parsed campaign: ${data.campaignId}");
                } catch (e) {
                  log("✗ Error parsing campaign: $e");
                }
              }
            }

            _data = jsonData;
            _error = null;
            log("Successfully loaded ${_data.length} campaigns");
            log("Active campaigns: ${activeCampaigns.length}");
            log("Inactive campaigns: ${inactiveCampaigns.length}");
          } else {
            _error = "Unexpected API response structure";
            _data = [];
          }
        } catch (e) {
          _error = "Failed to parse response: $e";
          _data = [];
          log("JSON parsing error: $e");
        }
      } else {
        _error = "Failed to fetch data (Code: ${response.statusCode})";
        _data = [];
      }
    } catch (e) {
      _error = "Error: $e";
      log("Unexpected error: $e");
      _data = [];
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

      log(campaign.toAddJson().toString());

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

  Future<String> updateCampaign(
    CampaignModel campaign,
    bool isStateUpdating,
  ) async {
    // Set loading state
    if (isStateUpdating) {
      _loadingId = campaign.campaignId;
    }
    notifyListeners();

    log("Data come AT provider: ${campaign.toJson()}");
    log("Updating Campaign: ${campaign.toJson()}");

    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/UpdateCampaign"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(campaign.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      log("Update API Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);

        // Check for success in response
        if (decoded['success'] == true || decoded['message'] != null) {
          // Refresh data
          await fetchData(true);
          return decoded["message"] ?? "Campaign updated successfully";
        } else {
          return "API returned unsuccessful response";
        }
      } else {
        log(
          "Update Campaign Failed: ${response.statusCode} => ${response.body}",
        );
        return "Failed with status ${response.statusCode}";
      }
    } catch (e) {
      log("Unexpected error: $e");
      return "Unexpected error: $e";
    } finally {
      _loadingId = null;
      notifyListeners();
    }
  }

  Future<String> deleteCampaign(int? campaignID, String? shopId) async {
    if (campaignID == null) {
      return "Campaign ID cannot be null";
    }

    try {
      final response = await http.delete(
        Uri.parse(
          "$baseUrl/DeleteCampaign?campaign_id=$campaignID&shop_id=$shopId",
        ),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        await fetchData(true); // refresh data after deletions
        String message = decoded["message"] ?? "Deleted successfully";
        return message;
      } else {
        final errorMsg =
            "Failed with ${response.statusCode} => ${response.body}";
        log(errorMsg);
        return errorMsg;
      }
    } catch (e, stackTrace) {
      return "Error: $e -> $stackTrace";
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
      final response = await http.get(
        Uri.parse("$baseUrl/GetCashback?shop_id=7866"),
      );

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
          log("No cashback data available from API.");
        }
      } else {
        _cashbackError = "Failed to fetch data (Code: ${response.statusCode})";
        log(_cashbackError.toString());
      }
    } catch (e) {
      _cashbackError = "Error: $e";
      log(_cashbackError.toString());
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
      log(model.toJson().toString());
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
        log("Cashback save failed: ${response.statusCode} -> ${response.body}");
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
    if (!isUpdate) _isReferralLoading = true;
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

  Future<String> addRestaurantReferralData(
    ReferredRestaurantsModel model,
  ) async {
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
    } finally {
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

  void setTogglingInactive(bool select) {
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
