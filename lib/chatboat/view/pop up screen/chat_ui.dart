import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../refer_and_earn/color_class.dart';
import '../../controller/chat_boat_controller.dart';
import '../../model/message_model.dart';
import '../../model/title_item.dart';
import '../widgets/in_chat_default_msg.dart';
import '../widgets/chat_history_existing_chat.dart';
import '../widgets/input_to_agent.dart';

class ChatUi extends StatefulWidget {
  const ChatUi({super.key, this.isMobile = false});
  final bool isMobile;

  @override
  State<ChatUi> createState() => _ChatUiState();
}

class _ChatUiState extends State<ChatUi> {
  @override
  Widget build(BuildContext context) {
    return widget.isMobile
        ? ChatUIMain()
        : Positioned(right: 20, bottom: 80, child: ChatUIMain());
  }
}

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
              InputToTheAgent(
                firstMsgController: firstMsgController,
                provider: provider,
                onMessageSent: _scrollToBottom, 
              ),
            ],
          ),
        ),
      ),
    );
  }
}
