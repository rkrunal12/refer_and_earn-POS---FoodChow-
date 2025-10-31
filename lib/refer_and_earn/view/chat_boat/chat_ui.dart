import 'dart:developer';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:refer_and_earn/refer_and_earn/color_class.dart';
import 'package:refer_and_earn/refer_and_earn/controller/provider/refer_provider.dart';
import '../../model/chatboat_model/message_model.dart';

class ChatUi extends StatefulWidget {
  const ChatUi({super.key, this.isMobile = false});
  final bool isMobile;

  @override
  State<ChatUi> createState() => _ChatUiState();
}

class _ChatUiState extends State<ChatUi> {
  final TextEditingController firstMsgController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReferralProvider>(context, listen: true);

    final MessageModel? currentChat = provider.chatItems
        .cast<MessageModel?>()
        .firstWhere((item) => item?.id == provider.chatId, orElse: () => null);

    final chatMessages = (currentChat != null)
        ? currentChat.data.title
        : <String>[];

    log(widget.isMobile.toString());

    return widget.isMobile
        ? ChatUIMain(
            widget: widget,
            provider: provider,
            chatMessages: chatMessages,
            firstMsgController: firstMsgController,
            scrollController: _scrollController,
          )
        : Positioned(
            right: 20,
            bottom: 80,
            child: ChatUIMain(
              widget: widget,
              provider: provider,
              chatMessages: chatMessages,
              firstMsgController: firstMsgController,
              scrollController: _scrollController,
            ),
          );
  }
}

class ChatUIMain extends StatelessWidget {
  const ChatUIMain({
    super.key,
    required this.widget,
    required this.provider,
    required this.chatMessages,
    required this.firstMsgController,
    required this.scrollController,
  });

  final ChatUi widget;
  final ReferralProvider provider;
  final List<String> chatMessages;
  final TextEditingController firstMsgController;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.isMobile
          ? double.infinity
          : provider.isChatUiExpanded
          ? 600
          : 400,
      height: widget.isMobile ? double.infinity : 650,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          child: Column(
            children: [
              // 🔹 Header
              if (!widget.isMobile)
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
                            onPressed: provider.backToList,
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
                          const Icon(Icons.menu, color: Colors.white),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: provider.setChatUiExpand,
                            icon: const Icon(
                              Icons.zoom_out_map_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // 🔹 Chat Body
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InChatDefaultMsg(
                        imgWidth: widget.isMobile
                            ? double.infinity
                            : provider.isChatUiExpanded
                            ? 600
                            : 400,
                      ),
                      if (chatMessages.isNotEmpty)
                        ...chatMessages.map((message) {
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
                                message,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: ColorsClass.blackColor,
                                ),
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),

              // 🔹 Message Input
              Padding(
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
                                vertical: 8,
                                horizontal: 10,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
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
                          icon: Icon(Icons.send, color: ColorsClass.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InChatDefaultMsg extends StatefulWidget {
  const InChatDefaultMsg({super.key, this.imgWidth = 400});
  final double imgWidth;

  @override
  State<InChatDefaultMsg> createState() => _InChatDefaultMsgState();
}

class _InChatDefaultMsgState extends State<InChatDefaultMsg> {
  YoutubePlayerController? youtubeController;
  String? videoId;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      videoId = YoutubePlayerController.convertUrlToId(
        'https://www.youtube.com/watch?v=cK7gv-gik9s',
      );
      youtubeController = YoutubePlayerController(
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          loop: false,
          enableCaption: true,
          captionLanguage: 'en',
        ),
      );
      youtubeController!.loadVideoById(videoId: videoId ?? 'cK7gv-gik9s');
    }
  }

  @override
  void dispose() {
    youtubeController?.close();
    super.dispose();
  }

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

          // YouTube Player
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
              child: kIsWeb
                  ? (youtubeController != null
                        ? YoutubePlayer(
                            controller: youtubeController!,
                            aspectRatio: 16 / 9,
                          )
                        : const Center(child: CircularProgressIndicator()))
                  : InkWell(
                      onTap: () {
                        Provider.of<ReferralProvider>(
                          context,
                          listen: false,
                        ).urlLaunch(
                          "https://www.youtube.com/watch?v=cK7gv-gik9s",
                        );
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: widget.imgWidth,
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
