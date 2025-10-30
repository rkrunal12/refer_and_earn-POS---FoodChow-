import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../model/campaign_model.dart';
import '../../model/cashback_model.dart';
import '../../model/chatboat_model/message_data.dart';
import '../../model/chatboat_model/message_model.dart';
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
  bool _isLoading = false;
  String? _error;
  dynamic _loadingId;
  List<CampaignModel> _data = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
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
            final List<CampaignModel> jsonData = [];
            for (var item in dataList) {
              if (item is Map<String, dynamic>) {
                final data = CampaignModel.fromJson(item);
                jsonData.add(data);
              }
            }

            _data = jsonData;
            _error = null;
          } else {
            _error = "Something went wrong, no data found.";
            _data = [];
          }
        } catch (e) {
          log("error parsing data: $e");
          _error = "Unexpected error, no data found.";
          _data = [];
        }
      } else {
        _error = "Unexpected error, no data found.";
        _data = [];
      }
    } catch (e) {
      log(e.toString());
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
    log("Campaign to update ${campaign.toJson()}");
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
      final saveCashbackData = jsonEncode(model.toJson());
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
      _referralList.where((c) => c.claimed == 1).toList();

  List<ReferredRestaurantsModel> get inactiveRefer =>
      _referralList.where((c) => c.claimed == 1).toList();

  List<ReferredRestaurantsModel> get pendingRefer =>
      _referralList.where((c) => c.claimed == 0).toList();

  Future<void> fetchRestaurantReferralData(bool isUpdate) async {
    if (!isUpdate) _isReferralLoading = true;
    _referralError = null;
    notifyListeners();

    try {
      final getReferralUrl =
          "$basereferralUrl/GetOwnReferredRestaurantsByShopId?shop_id=7866";
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
    } catch (e) {
      _referralError = "Unexpected error: $e";
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

  Future<void> deleteRestaurantReferralData(
    String? restaurantId,
    int? id,
  ) async {
    log(restaurantId ?? "No ID provided");
    log(id?.toString() ?? "No ID provided");
    final response = await http.delete(
      Uri.parse(
        "$basereferralUrl/DeleteReferredRestaurant?id=$id&restaurant_id=$restaurantId",
      ),
    );

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

  ///******************** Chat bost *********************///
  int chatIndex = 0;
  bool showPopUp = false;
  bool chatPopupPage = false;
  int? chatId;
  bool isChatUiExpanded = false;

  final List<MessageModel> chatItems = [];
  late Box<MessageModel> _chatBox;

  /// Initialize and load from Hive
  Future<void> init() async {
    _chatBox = Hive.box<MessageModel>('messages');
    chatItems.clear();
    chatItems.addAll(_chatBox.values);
    notifyListeners();
  }

  void setIndex(int index) {
    chatIndex = index;
    if (index == 0) {
      chatPopupPage = false;
    }
    notifyListeners();
  }

  void setChatUiExpand() {
    isChatUiExpanded = !isChatUiExpanded;
    notifyListeners();
  }

  void setPopUp() {
    showPopUp = !showPopUp;
    isChatUiExpanded = false;
    notifyListeners();
  }

  void setChatPopupPage(int? id) {
    chatPopupPage = true;
    chatId = id;
    notifyListeners();
  }

  void newChat() {
    chatPopupPage = true;
    chatId = chatItems.length + 1;
    notifyListeners();
  }

  void backToList() {
    chatPopupPage = false;
    chatId = null;
    notifyListeners();
  }

  /// Add new chat
  Future<void> addChat({required String title}) async {
    final newChat = MessageModel(
      id: chatItems.length + 1,
      data: MessageData(title: [title], time: DateTime.now()),
    );

    await _chatBox.put(newChat.id, newChat);
    chatItems.add(newChat);
    notifyListeners();
  }

  /// Add message to existing chat
  Future<void> addMessageToChat({required String message}) async {
    if (chatId == null) return;

    final chat = chatItems.firstWhere(
      (c) => c.id == chatId,
      orElse: () => MessageModel(
        id: -1,
        data: MessageData(title: [], time: DateTime.now()),
      ),
    );

    if (chat.id != -1) {
      chat.data.title.add(message);
      chat.data.time = DateTime.now();

      await chat.save(); // Saves changes to Hive automatically
      notifyListeners();
    }
  }
}
