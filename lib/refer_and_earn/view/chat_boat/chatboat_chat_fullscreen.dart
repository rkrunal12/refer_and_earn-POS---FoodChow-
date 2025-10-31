import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../../model/chatboat_model/message_model.dart';
import 'chat_ui.dart';

class ChatboatChatFullScreen extends StatefulWidget {
  const ChatboatChatFullScreen({super.key});

  @override
  State<ChatboatChatFullScreen> createState() => _ChatboatChatFullScreenState();
}

class _ChatboatChatFullScreenState extends State<ChatboatChatFullScreen> {
  final TextEditingController firstMsgController = TextEditingController();

  String _getTimeDifference(String timeString) {
    try {
      final chatTime = DateTime.parse(timeString);
      final diff = DateTime.now().difference(chatTime);

      if (diff.inSeconds < 60) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return timeString;
    }
  }

  @override
  void dispose() {
    firstMsgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReferralProvider>(context);
    final small = MediaQuery.of(context).size.width < 1000;

    final currentChat = (provider.chatId != null)
        ? provider.chatItems
              .where((item) => item.id == provider.chatId)
              .cast<MessageModel?>()
              .firstOrNull
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 13.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                if (provider.chatItems.isEmpty)
                  const Center(child: Text("Get started with your first query"))
                else
                  ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          "Chat History",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      ...provider.chatItems.map(
                        (item) => Card(
                          elevation: 1,
                          color: Colors.white,
                          child: ListTile(
                            onTap: () => provider.setChatPopupPage(item.id),
                            leading: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Image.asset(
                                "assets/images/logo_foodchow.png",
                                width: 30,
                                height: 30,
                              ),
                            ),
                            title: Text(
                              item.data.title.isNotEmpty
                                  ? item.data.title.first
                                  : "New chat",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              _getTimeDifference(item.data.time.toString()),
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),

                // 🔹 Floating New Chat Button
                Positioned(
                  bottom: 20,
                  left: 40,
                  right: 40,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsClass.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => provider.setChatPopupPage(null),
                    icon: const Icon(Icons.message_sharp, color: Colors.white),
                    label: !small
                        ? Text(
                            "New Conversation",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),

          // 🔹 Divider
          Container(width: 2, color: ColorsClass.deviderColor),

          // 🔹 Chat Window
          Expanded(
            flex: 3,
            child: provider.chatPopupPage
                ? Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const InChatDefaultMsg(),

                              // ✅ Chat messages
                              if (currentChat != null &&
                                  currentChat.data.title.isNotEmpty)
                                ...currentChat.data.title.map((msg) {
                                  return Align(
                                    alignment: Alignment.bottomRight,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      margin: const EdgeInsets.only(top: 8),
                                      decoration: BoxDecoration(
                                        color: ColorsClass.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        msg,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: ColorsClass.blackColor,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              if (currentChat == null ||
                                  currentChat.data.title.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(top: 20.0),
                                  child: Center(
                                    child: Text(
                                      "Start a new conversation below 👇",
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // 🔹 Input bar
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(40),
                            ),
                            border: Border.all(
                              color: ColorsClass.primary,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: firstMsgController,
                                  textInputAction: TextInputAction.send,
                                  onSubmitted: (value) {
                                    final text = firstMsgController.text.trim();
                                    if (text.isEmpty) return;

                                    if (provider.chatId == null) {
                                      provider.addChat(title: text);
                                      provider.newChat();
                                    } else {
                                      provider.addMessageToChat(message: text);
                                    }

                                    firstMsgController.clear();
                                  },
                                  decoration: const InputDecoration(
                                    hintText: "Ask a question...",
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 15,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.send,
                                  color: ColorsClass.primary,
                                ),
                                onPressed: () {
                                  final text = firstMsgController.text.trim();
                                  if (text.isEmpty) return;

                                  if (provider.chatId == null) {
                                    provider.addChat(title: text);
                                    provider.newChat();
                                  } else {
                                    provider.addMessageToChat(message: text);
                                  }

                                  firstMsgController.clear();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
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
}
