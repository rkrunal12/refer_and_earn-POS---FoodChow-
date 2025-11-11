import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../refer_and_earn/color_class.dart';
import '../controller/chat_boat_controller.dart';
import '../model/message_model.dart';

import 'widgets.dart';

class ChatboatChatFullScreen extends StatefulWidget {
  const ChatboatChatFullScreen({super.key});

  @override
  State<ChatboatChatFullScreen> createState() => _ChatboatChatFullScreenState();
}

class _ChatboatChatFullScreenState extends State<ChatboatChatFullScreen> {
  final TextEditingController firstMsgController = TextEditingController();
  final ScrollController _scrollController =
      ScrollController(); // Add ScrollController

  // Helper function to scroll to bottom
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    firstMsgController.dispose();
    _scrollController.dispose(); // Dispose ScrollController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChatBoatProvider>(context);
    final small = MediaQuery.of(context).size.width < 900;
    final currentChat = (provider.chatIdChatUi != null)
        ? provider.chatItems
              .where((item) => item.id == provider.chatIdChatUi)
              .cast<MessageModel?>()
              .firstOrNull
        : null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 13.0),
      child: small
          ? _chatScreen(currentChat, provider)
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 1, child: ChatSideBar()),
                Container(width: 2, color: ColorsClass.deviderColor),
                Expanded(
                  flex: 3,
                  child: provider.chatPopupPage
                      ? _chatScreen(currentChat, provider)
                      : const Center(
                          child: Text(
                            "The chat will appear here",
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Column _chatScreen(MessageModel? currentChat, ChatBoatProvider provider) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController, // Assign ScrollController
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const InChatDefaultMsg(),
                if (currentChat != null &&
                    currentChat.data.chatHistory.isNotEmpty)
                  ...currentChat.data.chatHistory.map((msg) {
                    return ChatHistoryExistingChat(message: msg);
                  }),
                if (currentChat == null || currentChat.data.chatHistory.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Center(
                      child: Text("Start a new conversation below 👇"),
                    ),
                  ),
              ],
            ),
          ),
        ),
        InputToTheAgent(
          provider: provider,
          firstMsgController: firstMsgController,
          onMessageSent: _scrollToBottom, // Pass scroll function
        ),
      ],
    );
  }
}

