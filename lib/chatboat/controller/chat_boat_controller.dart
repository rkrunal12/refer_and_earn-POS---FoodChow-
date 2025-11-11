import "dart:convert";
import "dart:math";
import "package:flutter/material.dart";
import "package:hive/hive.dart";
import "package:http/http.dart" as http;
import "package:refer_and_earn/refer_and_earn/view/widgets/common_widget.dart";
import "package:url_launcher/url_launcher.dart";

import "../model/get_conversation_data_model.dart";
import "../model/message_data.dart";
import "../model/message_model.dart";
import "../model/send_question_model.dart";
import "../model/title_item.dart";

class ChatBoatProvider with ChangeNotifier {
  ///******************** Chat bot *********************///
  int chatBoatPupupIndex = 0;
  bool showChatBoatPopup = false;
  bool chatPopupPage = false;
  int? chatIdChatUi;
  bool isChatboatPopUpExpand = false;

  final List<MessageModel> chatItems = [];
  late Box<MessageModel> _chatBox;

  Future<void> init() async {
    _chatBox = await Hive.openBox<MessageModel>('messages');
    chatItems.clear();
    List<MessageModel> messages = _chatBox.values.toList();
    messages.sort((a, b) => b.data.time.compareTo(a.data.time));
    chatItems.addAll(messages);
    notifyListeners();
  }

  void setChatBoatPopupIndex(int index) {
    chatBoatPupupIndex = index;
    if (index == 0) {
      chatPopupPage = false;
    }
    notifyListeners();
  }

  void setChatUiExpand() {
    isChatboatPopUpExpand = !isChatboatPopUpExpand;
    notifyListeners();
  }

  void setShowChatBoatPopup() {
    showChatBoatPopup = !showChatBoatPopup;
    isChatboatPopUpExpand = false;
    chatPopupPage = false;
    notifyListeners();
  }

  void setChatPopupPage(int? id) {
    chatPopupPage = true;
    chatIdChatUi = id;
    notifyListeners();
  }

  void startNewChat() {
    chatPopupPage = true;
    notifyListeners();
  }

  void backToChatListScreen() {
    chatPopupPage = false;
    chatIdChatUi = null;
    notifyListeners();
  }

  Future<void> addNewChat({required String question}) async {
    final tempId = _generateUniqueId();

    final tempChat = MessageModel(
      id: tempId,
      data: MessageData(
        chatHistory: [
          TitleItem(
            message: question,
            replyFromBot: {
              "id": "temp_$tempId",
              "reply": "Thinking...",
              "like": null,
              "isLoading": true,
            },
          ),
        ],
        time: DateTime.now(),
      ),
    );

    chatItems.add(tempChat);
    chatIdChatUi = tempId;
    notifyListeners();

    try {
      final chatData = await sendQuestion(question: question);
      final chatIndex = chatItems.indexWhere((c) => c.id == tempId);

      if (chatIndex != -1) {
        final finalChat = MessageModel(
          id: tempId,
          data: MessageData(
            chatHistory: [
              TitleItem(
                message: chatData.userQuestionFromResponse ?? question,
                replyFromBot: {
                  "id": chatData.id ?? _generateUniqueId(),
                  "reply": chatData.agentAnswerFromResponse,
                  "like": null,
                  "isLoading": false,
                },
              ),
            ],
            time: DateTime.now(),
          ),
        );

        chatItems[chatIndex] = finalChat;

        await _chatBox.put(tempId, finalChat);
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> addMessageToExistingChat({required String question}) async {
    if (chatIdChatUi == null) return;

    final tempMessageId = "temp_msg_${DateTime.now().millisecondsSinceEpoch}";

    // 2. Create temporary message
    final tempMessage = TitleItem(
      message: question,
      replyFromBot: {
        "id": tempMessageId,
        "reply": "Thinking...",
        "like": null,
        "isLoading": true,
      },
    );

    final chatIndex = chatItems.indexWhere((c) => c.id == chatIdChatUi);
    if (chatIndex == -1) return;

    chatItems[chatIndex].data.chatHistory.add(tempMessage);
    chatItems[chatIndex].data.time = DateTime.now();
    notifyListeners();

    try {
      final chatData = await sendQuestion(question: question);

      final messageIndex = chatItems[chatIndex].data.chatHistory.indexWhere(
        (msg) => msg.replyFromBot["id"] == tempMessageId,
      );

      if (messageIndex != -1) {
        chatItems[chatIndex].data.chatHistory[messageIndex] = TitleItem(
          message: question,
          replyFromBot: {
            "id": chatData.id ?? _generateUniqueId(),
            "reply": chatData.agentAnswerFromResponse,
            "like": null,
            "isLoading": false,
          },
        );

        chatItems[chatIndex].data.time = DateTime.now();
        await _chatBox.put(chatIdChatUi!, chatItems[chatIndex]);
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  int _generateUniqueId() {
    final random = Random();
    return 1000 + random.nextInt(0xFFFFFFFE - 1000);
  }

  void urlLaunch(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  bool _isEmojiVisible = false;
  bool get isEmojiVisible => _isEmojiVisible;

  final FocusNode inputFocusNode = FocusNode();

  void toggleEmojiPicker(bool isOpen) {
    if (!isOpen) {
      _isEmojiVisible = isOpen;
      notifyListeners();
    } else {
      _isEmojiVisible = isOpen;
      inputFocusNode.unfocus(); // hide keyboard
      notifyListeners();
    }
  }

  void hideEmojiPicker() {
    if (_isEmojiVisible) {
      _isEmojiVisible = false;
      notifyListeners();
    }
  }

  /// ******************** chat bot API ********************///

  Future<GetConversationDataModel> sendQuestion({
    required String? question,
  }) async {
    final data = SendQuestionModel(question: question);
    final url = "https://chatbot-backend-api-j4zs.onrender.com/query/query";
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final questionData = SendQuestionModel.fromJson(decoded);
        final ans = questionData.answer;
        final getAnswer = await getConversationData(
          question: question ?? "",
          answer: ans ?? "",
        );
        CustomeToast.showSuccess("Answer : $ans");

        return getAnswer;
      } else {
        // CustomeToast.showError("${response.statusCode} -> ${response.body}");
        debugPrint("${response.statusCode} -> ${response.body}");
        debugPrint("Url : $url");
        debugPrint("Post Data -> ${data.toJson()}");
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return GetConversationDataModel();
  }

  Future<GetConversationDataModel> getConversationData({
    required String question,
    required String answer,
  }) async {
    final data = GetConversationDataModel(
      userQuestion: question,
      agentAnswer: answer,
    );
    try {
      final response = await http.post(
        Uri.parse(
          "https://chatbot-backend-api-j4zs.onrender.com/conversation/agents/68df6c4b3d1052916ddbccdd/conversations",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);

        final data = GetConversationDataModel.fromJson(decoded);
        return data;
      } else {
        CustomeToast.showError("${response.statusCode} -> ${response.body}");
        debugPrint("${response.statusCode} -> ${response.body}");
        return GetConversationDataModel();
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {}
    return GetConversationDataModel();
  }

  Future<void> feedbackOfReply({
    required String replyId,
    required bool like,
  }) async {
    final chatIndex = chatItems.indexWhere(
      (chat) => chat.data.chatHistory.any(
        (item) => item.replyFromBot["id"] == replyId,
      ),
    );

    if (chatIndex != -1) {
      final chat = chatItems[chatIndex];
      for (var item in chat.data.chatHistory) {
        if (item.replyFromBot["id"] == replyId) {
          item.replyFromBot["like"] = like;
          break;
        }
      }
      await _chatBox.put(chat.id, chat);
      notifyListeners();

      final agentId = SendQuestionModel.agentId;
      final url =
          "https://chatbot-backend-api-j4zs.onrender.com/conversation/feedback/$agentId/$replyId";

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'feedback': like ? "like" : "dislike"}),
        );

        if (response.statusCode == 200 && response.statusCode == 201) {
          debugPrint("Feedback sent successfully");
        } else {
          debugPrint(
            "Feedback error: ${response.statusCode} -> ${response.body}",
          );
          // Optionally revert the local state if the API call fails
        }
      } catch (e) {
        debugPrint("Feedback error: $e");
        // Optionally revert the local state if the API call fails
      }
    }
  }
}
