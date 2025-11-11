import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart' show Lottie;
import 'package:provider/provider.dart' show Provider, Consumer;

import '../../refer_and_earn/color_class.dart';
import '../controller/chat_boat_controller.dart';
import '../model/message_model.dart';
import '../model/title_item.dart';

class ChatUIMain extends StatefulWidget {
  const ChatUIMain({super.key});

  @override
  State<ChatUIMain> createState() => _ChatUIMainState();
}

class _ChatUIMainState extends State<ChatUIMain> {
  final TextEditingController firstMsgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    firstMsgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 500;
    final provider = Provider.of<ChatBoatProvider>(context, listen: true);
    final MessageModel? currentChat = provider.chatItems
        .cast<MessageModel?>()
        .firstWhere(
          (item) => item?.id == provider.chatIdChatUi,
          orElse: () => null,
        );
    final chatMessages = (currentChat != null)
        ? currentChat.data.chatHistory
        : <TitleItem>[];

    return SizedBox(
      width: isMobile
          ? double.infinity
          : provider.isChatboatPopUpExpand
          ? 600
          : 400,
      height: isMobile ? double.infinity : 650,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          child: Column(
            children: [
              if (!isMobile)
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: ColorsClass.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: provider.backToChatListScreen,
                            icon: const Icon(
                              Icons.arrow_back_ios_new_outlined,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Foodchow AI Bot",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/icon-three-dots.png",
                            height: 25,
                            width: 25,
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: provider.setChatUiExpand,
                            icon: Image.asset(
                              provider.isChatboatPopUpExpand
                                  ? "assets/images/arrow-small.png"
                                  : "assets/images/arrow.png",
                              height: 25,
                              width: 25,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              // Chat messages
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InChatDefaultMsg(
                        imgWidth: isMobile
                            ? double.infinity
                            : provider.isChatboatPopUpExpand
                            ? 600
                            : 400,
                      ),
                      if (chatMessages.isNotEmpty)
                        ...chatMessages.map((message) {
                          return ChatHistoryExistingChat(message: message);
                        }),
                    ],
                  ),
                ),
              ),
              // Input field
              InputToTheAgent(
                firstMsgController: firstMsgController,
                provider: provider,
                onMessageSent: _scrollToBottom, // Pass scroll function
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatSideBar extends StatelessWidget {
  final VoidCallback? onItemTap;

  const ChatSideBar({super.key, this.onItemTap});

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
  Widget build(BuildContext context) {
    final provider = Provider.of<ChatBoatProvider>(context);

    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
            child: Text(
              "Chat History",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: provider.chatItems.isEmpty
                ? Center(
                    child: Text(
                      "Get started with your first query",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    itemCount: provider.chatItems.length,
                    itemBuilder: (context, index) {
                      final item = provider.chatItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        elevation: 1,
                        color: Colors.white,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          onTap: () {
                            provider.setChatPopupPage(item.id);
                            if (onItemTap != null) {
                              onItemTap!();
                            }
                          },
                          leading: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Image.asset(
                              "assets/images/logo_foodchow.png",
                              width: 30,
                              height: 30,
                            ),
                          ),
                          title: Text(
                            item.data.chatHistory.isNotEmpty
                                ? item.data.chatHistory[0].message.length > 25
                                      ? "${item.data.chatHistory[0].message.substring(0, 25)}..."
                                      : item.data.chatHistory[0].message
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
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsClass.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                provider.setChatPopupPage(null);
                if (onItemTap != null) {
                  onItemTap!();
                }
              },
              icon: const Icon(Icons.message_sharp, color: Colors.white),
              label: Text(
                "New Conversation",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InputToTheAgent extends StatelessWidget {
  const InputToTheAgent({
    super.key,
    required this.provider,
    required this.firstMsgController,
    required this.onMessageSent,
  });

  final ChatBoatProvider provider;
  final TextEditingController firstMsgController;
  final VoidCallback onMessageSent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: ColorsClass.white,
          borderRadius: const BorderRadius.all(Radius.circular(40)),
          border: Border.all(color: ColorsClass.primary, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: firstMsgController,
                  focusNode: provider.inputFocusNode,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (value) {
                    final text = firstMsgController.text.trim();
                    if (text.isEmpty) return;
                    if (provider.chatIdChatUi == null) {
                      provider.addNewChat(question: text);
                      provider.startNewChat();
                    } else {
                      provider.addMessageToExistingChat(question: text);
                    }
                    firstMsgController.clear();
                    onMessageSent(); // Scroll to bottom after sending
                  },
                  decoration: const InputDecoration(
                    hintText: "Ask a question...",
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 10,
                    ),
                  ),
                ),
              ),
              InkWell(
                child: const Padding(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Icon(Icons.send, color: ColorsClass.primary),
                ),
                onTap: () {
                  final text = firstMsgController.text.trim();
                  if (text.isEmpty) return;
                  if (provider.chatIdChatUi == null) {
                    provider.addNewChat(question: text);
                  } else {
                    provider.addMessageToExistingChat(question: text);
                  }
                  firstMsgController.clear();
                  onMessageSent(); // Scroll to bottom after sending
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatHistoryExistingChat extends StatelessWidget {
  const ChatHistoryExistingChat({super.key, required this.message});
  final TitleItem message;

  bool get _isLoading => message.replyFromBot["isLoading"] == true;
  bool get _isError => message.replyFromBot["isError"] == true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message.message,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ColorsClass.blackColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: _isLoading
              ? Lottie.asset(
                  "assets/lottie/3-dot.json",
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                )
              : Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: _isError
                        ? Colors.red.withOpacity(0.1)
                        : ColorsClass.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 13,
                                backgroundColor: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Image.asset(
                                    "assets/images/logo_foodchow.png",
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Foodchow AI Assistant",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: ColorsClass.blackColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              message.replyFromBot["reply"] ?? "",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _isError
                                    ? Colors.red
                                    : ColorsClass.blackColor,
                              ),
                            ),
                          ),
                          if (!_isLoading) const SizedBox(height: 20),
                        ],
                      ),
                      if (!_isLoading && !_isError)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Consumer<ChatBoatProvider>(
                            builder: (context, value, _) {
                              final isLiked = message.replyFromBot["like"];
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      value.feedbackOfReply(
                                        replyId: message.replyFromBot["id"],
                                        like: true,
                                      );
                                    },
                                    child: SvgPicture.asset(
                                      isLiked == true
                                          ? "assets/svg/like-filled.svg"
                                          : "assets/svg/like.svg",
                                      color: isLiked == true
                                          ? Colors.green
                                          : Colors.grey,
                                      height: isLiked == true ? 20 : null,
                                      width: isLiked == true ? 20 : null,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  InkWell(
                                    onTap: () {
                                      value.feedbackOfReply(
                                        replyId: message.replyFromBot["id"],
                                        like: false,
                                      );
                                    },
                                    child: SvgPicture.asset(
                                      isLiked == false
                                          ? "assets/svg/dislike-filled.svg"
                                          : "assets/svg/dislike.svg",
                                      color: isLiked == false
                                          ? Colors.red
                                          : Colors.grey,
                                      height: isLiked == false ? 20 : null,
                                      width: isLiked == false ? 20 : null,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class InChatDefaultMsg extends StatelessWidget {
  const InChatDefaultMsg({super.key, this.imgWidth = 400});
  final double imgWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: ColorsClass.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Image.asset(
                    "assets/images/logo_foodchow.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "Foodchow AI Assistant",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ColorsClass.blackColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Hello 😊",
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: ColorsClass.blackColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Are you looking for a powerful marketing system to grow your business?",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: ColorsClass.blackColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "This video explains how FoodChow works and helps you get more clients, profits, and productivity.",
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: ColorsClass.blackColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Get in touch with our team and we'll be happy to help!",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: ColorsClass.blackColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () {
                  Provider.of<ChatBoatProvider>(
                    context,
                    listen: false,
                  ).urlLaunch("https://www.youtube.com/watch?v=cK7gv-gik9s");
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: imgWidth,
                      height: double.infinity,
                      child: Image.network(
                        'https://img.youtube.com/vi/cK7gv-gik9s/sddefault.jpg',
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Text("Could not load thumbnail"),
                          );
                        },
                      ),
                    ),
                    const Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 50,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
