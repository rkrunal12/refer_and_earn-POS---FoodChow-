import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:refer_and_earn/refer_and_earn/view/widgets/common_widgets.dart';

import '../../model/campaign_model.dart';
import '../../model/cashback_model.dart';
import '../../model/fetch_data_model.dart';
import '../../model/referral_row_data.dart';
import '../../model/referred_restrauant_model.dart';

class ReferralProvider with ChangeNotifier {
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
      final fetchUrl = "$baseUrl/CampaignsByShop?shopId=7866";
      final response = await http
          .get(Uri.parse(fetchUrl))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        try {
          final decoded = jsonDecode(response.body);

          if (decoded['data'] != null && decoded['data'].isNotEmpty) {
            final List<dynamic> dataList = decoded['data'][0];
            final List<Data> jsonData = [];
            for (var item in dataList) {
              if (item is Map<String, dynamic>) {
                final data = Data.fromJson(item);
                jsonData.add(data);
              }
            }

            _data = jsonData;
            _error = null;
          } else {
            _error = "Something went wrong, no data found.";
            _data = [];
          }
        } catch (_) {
          _error = "Unexpected error, no data found.";
          _data = [];
        }
      } else {
        _error = "Unexpected error, no data found.";
        _data = [];
      }
    } catch (_) {
      _error = "Unexpected error";
      _data = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCampaign(CampaignModel campaign) async {
    _loadingId = 1;
    notifyListeners();

    try {
      final addUrl = "$baseUrl/AddCampaign";
      final addData = jsonEncode(campaign.toAddJson());

      final response = await http.post(
        Uri.parse(addUrl),
        headers: {"Content-Type": "application/json"},
        body: addData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchData(false);
        CustomeToast.showSuccess("Campaign added successfully");
      } else {
        CustomeToast.showError("Something went wrong");
      }
    } catch (_) {
      CustomeToast.showError("Unexpected error");
    } finally {
      _loadingId = null;
      notifyListeners();
    }
  }

  Future<void> updateCampaign(
    CampaignModel campaign,
    bool isStateUpdating,
  ) async {
    if (isStateUpdating) {
      _loadingId = campaign.campaignId;
    }
    notifyListeners();

    try {
      final updateUrl = "$baseUrl/UpdateCampaign";
      final updateData = jsonEncode(campaign.toJson());
      final response = await http
          .post(
            Uri.parse(updateUrl),
            headers: {"Content-Type": "application/json"},
            body: updateData,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true || decoded['message'] != null) {
          await fetchData(true);
          CustomeToast.showSuccess(
            decoded["message"] ?? "Campaign updated successfully",
          );
        } else {
          CustomeToast.showError("Something went wrong");
        }
      } else {
        CustomeToast.showError("Something went wrong");
      }
    } catch (_) {
      CustomeToast.showError("Unexpected error");
    } finally {
      _loadingId = null;
      notifyListeners();
    }
  }

  Future<void> deleteCampaign(int? campaignID, String? shopId) async {
    try {
      final deleteUrl =
          "$baseUrl/DeleteCampaign?campaign_id=$campaignID&shop_id=$shopId";
      final response = await http.delete(
        Uri.parse(deleteUrl),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchData(true);
        CustomeToast.showSuccess("Deleted successfully");
      } else {
        CustomeToast.showError("Failed with some error");
      }
    } catch (_) {
      CustomeToast.showError("Unexpected error");
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

  Future<void> fetchCashbackData(bool isAdd) async {
    if (isAdd) _isCashbackGetLoading = true;
    _cashbackError = null;
    notifyListeners();

    try {
      final fetchCashbackUrl = "$baseUrl/GetCashback?shop_id=7866";
      final response = await http.get(Uri.parse(fetchCashbackUrl));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded["data"] != null && decoded["data"].isNotEmpty) {
          final cashbackJson = decoded["data"][0];
          _allCashback = CashbackModel.fromJson(cashbackJson);

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
        }
      } else {
        _cashbackError = "Something went wrong";
      }
    } catch (_) {
      _cashbackError = "Unexpected error";
    } finally {
      _isCashbackGetLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveCashback(CashbackModel model) async {
    _isCashbackAddLoading = true;
    notifyListeners();

    try {
      final isUpdate = model.cashbackId != null;
      final saveCashbackUrl = isUpdate
          ? "$baseUrl/UpdateCashback"
          : "$baseUrl/AddCashback";
      final saveCashbackData = jsonEncode(model.toAddJson());
      final response = await http.post(
        Uri.parse(saveCashbackUrl),
        body: saveCashbackData,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final decode = jsonDecode(response.body);
        await fetchCashbackData(false);
        CustomeToast.showSuccess(decode["message"] ?? "Success");
      } else {
        CustomeToast.showError("Something went wrong");
      }
    } catch (_) {
      CustomeToast.showError("Unexpected error");
    } finally {
      _isCashbackAddLoading = false;
      notifyListeners();
    }
  }

  /// ********************************* Referral Api Data **************************///
  bool _isReferralLoading = false;
  String? _referralError;
  List<ReferredRestaurantsModel> _referralList = [];
  final basereferralUrl = "https://api.foodchow.com/api/Restaurant_Refer_Earn";

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
      final getReferralUrl = "$basereferralUrl/GetReferredRestaurants";
      final response = await http.get(Uri.parse(getReferralUrl));
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
        _referralError = "Something went wrong";
      }
    } catch (_) {
      _referralError = "Unexpected error";
    } finally {
      _isReferralLoading = false;
      notifyListeners();
    }
  }

  Future<void> addRestaurantReferralData(ReferredRestaurantsModel model) async {
    final addreferralUrl = "$basereferralUrl/AddReferredRestaurants";
    final addReferralData = jsonEncode(model.toJson());
    final response = await http.post(
      Uri.parse(addreferralUrl),
      headers: {"Content-Type": "application/json"},
      body: addReferralData,
    );

    try {
      if (response.statusCode == 200) {
        final decode = jsonDecode(response.body);
        await fetchRestaurantReferralData(true);
        CustomeToast.showSuccess(decode["message"] ?? "Success");
      } else {
        CustomeToast.showError("Something went wrong");
      }
    } on Exception {
      CustomeToast.showError("Unexpected error");
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteRestaurantReferralData(String? restaurantId) async {
    notifyListeners();
    final response = await http.delete(
      Uri.parse("$basereferralUrl/DeleteReferredRestaurant/$restaurantId"),
    );

    try {
      if (response.statusCode == 204) {
        await fetchRestaurantReferralData(true);
        CustomeToast.showSuccess("Delete Success");
      } else {
        CustomeToast.showError("Something went wrong");
      }
    } on Exception {
      CustomeToast.showError("Unexpected error");
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

  double get fixedDiscount => _fixedDiscount;
  double get percentageDiscount => _percentageDiscount;
  bool get isEnables => _isEnables;
  String get rewardCashbackType => _rewardCashbackType;

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

  /// ********************************* Restaurant referral screen **************************///
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
}
