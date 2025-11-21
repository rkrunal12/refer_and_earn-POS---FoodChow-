import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../model/campaign_model.dart';
import '../../model/cashback_model.dart';
import '../../model/referral_row_data.dart';
import '../../model/referred_restrauant_model.dart';
import '../../view/widgets/common_widget.dart';

class ReferralProvider with ChangeNotifier {
  /// ********************************* Campaign API **************************///
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  void setSelectedIndex(int value) {
    _selectedIndex = value;
    notifyListeners();
  }

  String baseUrl = "https://api.foodchow.com/api/Refer_and_earn";
  final contentTypeHeader = {"Content-Type": "application/json"};
  bool _isLoading = false;
  dynamic _loadingId;
  List<CampaignModel> _data = [];

  bool get isLoading => _isLoading;
  dynamic get loadingId => _loadingId;
  List<CampaignModel> get data => _data;

  List<CampaignModel> get activeCampaigns =>
      _data.where((c) => c.statusStr == "1").toList();

  List<CampaignModel> get inactiveCampaigns =>
      _data.where((c) => c.statusStr == "0").toList();

  int get totalReferrals =>
      _data.fold(0, (sum, c) => sum + (c.referrerReward ?? 0));

  Future<void> fetchData(bool isUpdating) async {
    if (!isUpdating) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final fetchUrl = Uri.parse("$baseUrl/CampaignsByShop?shopId=7866");
      final response = await http
          .get(fetchUrl)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        try {
          final decoded = jsonDecode(response.body);

          if (decoded['data'] != null && decoded['data'].isNotEmpty) {
            final List<dynamic> dataList = decoded['data'][0];
            final List<CampaignModel> jsonData = [];
            for (var item in dataList) {
              if (item is Map<String, dynamic>) {
                final data = CampaignModel.fromJson(item);
                jsonData.add(data);
              }
            }
            _data = jsonData;
          } else {
            _data = [];
          }
        } catch (e) {
          CustomeToast.showError("Data Error");
          _data = [];
        }
      } else {
        CustomeToast.showError("Something went wrong");
        _data = [];
      }
    } catch (e) {
      CustomeToast.showError("Something went wrong");
      debugPrint(e.toString());
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
      final addUrl = Uri.parse("$baseUrl/AddCampaign");
      final addData = jsonEncode(campaign.toAddJson());

      final response = await http.post(
        addUrl,
        headers: contentTypeHeader,
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
      final updateUrl = Uri.parse("$baseUrl/UpdateCampaign");
      final updateData = jsonEncode(campaign.toUpdateJson());
      final response = await http
          .post(updateUrl, headers: contentTypeHeader, body: updateData)
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
      final deleteUrl = Uri.parse(
        "$baseUrl/DeleteCampaign?campaign_id=$campaignID&shop_id=$shopId",
      );
      final response = await http.delete(deleteUrl, headers: contentTypeHeader);

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

  bool get isCashbackGetLoading => _isCashbackGetLoading;
  bool get isCashbackAddLoading => _isCashbackAddLoading;
  CashbackModel? get allCashback => _allCashback;

  Future<void> fetchCashbackData(bool isAdd) async {
    if (isAdd) _isCashbackGetLoading = true;
    notifyListeners();

    try {
      final fetchCashbackUrl = Uri.parse("$baseUrl/GetCashback?shop_id=7866");
      final response = await http.get(fetchCashbackUrl);

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
        CustomeToast.showError("Something went wrong");
      }
    } catch (_) {
      CustomeToast.showError("Unexpected error");
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
      final saveCashbackUrl = Uri.parse(
        isUpdate ? "$baseUrl/UpdateCashback" : "$baseUrl/AddCashback",
      );
      final saveCashbackData = jsonEncode(model.toJson());
      final response = await http.post(
        saveCashbackUrl,
        body: saveCashbackData,
        headers: contentTypeHeader,
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
  List<ReferredRestaurantsModel> _referralList = [];
  final basereferralUrl = "https://api.foodchow.com/api/Restaurant_Refer_Earn";

  bool get isReferralLoading => _isReferralLoading;
  List<ReferredRestaurantsModel> get referralList => _referralList;

  List<ReferredRestaurantsModel> get activeRefer =>
      _referralList.where((c) => c.claimed == 1).toList();

  List<ReferredRestaurantsModel> get inactiveRefer =>
      _referralList.where((c) => c.claimed == 1).toList();

  List<ReferredRestaurantsModel> get pendingRefer =>
      _referralList.where((c) => c.claimed == 0).toList();

  Future<void> fetchRestaurantReferralData(bool isUpdate) async {
    if (!isUpdate) _isReferralLoading = true;
    notifyListeners();

    try {
      final getReferralUrl = Uri.parse(
        "$basereferralUrl/GetReferredRestaurantsByShopId?shop_id=7866",
      );
      final response = await http.get(getReferralUrl);
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
        CustomeToast.showError("Something went wrong");
      }
    } catch (e) {
      CustomeToast.showError("Unexpected error: $e");
    } finally {
      _isReferralLoading = false;
      notifyListeners();
    }
  }

  Future<void> addRestaurantReferralData(ReferredRestaurantsModel model) async {
    final addreferralUrl = Uri.parse("$basereferralUrl/AddReferredRestaurants");
    final addReferralData = jsonEncode(model.toJson());
    final response = await http.post(
      addreferralUrl,
      headers: contentTypeHeader,
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

  Future<void> deleteRestaurantReferralData(
    String? restaurantId,
    int? id,
  ) async {
    final deleteUrl = Uri.parse(
      "$basereferralUrl/DeleteReferredRestaurant?id=$id&restaurant_id=$restaurantId",
    );
    final response = await http.delete(deleteUrl);

    try {
      if (response.statusCode == 204 || response.statusCode == 200) {
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
  double minimumPrice = 0;
  String termsCodition = "Not Applicable for baverages";
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

  void setMimimumPriceEdiitngEnable(double price) {
    minimumPrice = price;
    notifyListeners();
  }

  void setTermsAndConditions(String value) {
    termsCodition = value;
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
