import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:refer_and_earn/refer_and_earn/color_class.dart';
import 'package:refer_and_earn/refer_and_earn/view/chat_boat/chat_ui.dart';
import 'package:refer_and_earn/refer_and_earn/view/chat_boat/chatboat_chat.dart';
import 'package:refer_and_earn/refer_and_earn/view/chat_boat/chatboat_chat_fullscreen.dart';
import 'package:refer_and_earn/refer_and_earn/view/chat_boat/chatboat_home.dart';

import '../../controller/provider/refer_provider.dart';

class ChatboatFullscreen extends StatefulWidget {
  const ChatboatFullscreen({super.key});

  @override
  State<ChatboatFullscreen> createState() => _ChatboatFullscreenState();
}

class _ChatboatFullscreenState extends State<ChatboatFullscreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<ReferralProvider>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 500;

    return Scaffold(
      appBar: AppBar(
        leading: Consumer<ReferralProvider>(
          builder: (context, value, _) {
            if (isMobile && value.chatPopupPage) {
              return IconButton(
                onPressed: () {
                  value.backToList();
                },
                icon: Icon(
                  Icons.arrow_back_ios_new_outlined,
                  color: Colors.white,
                ),
              );
            } else {
              return SizedBox.shrink();
            }
          },
        ),
        backgroundColor: ColorsClass.primary,
        title: SvgPicture.asset(
          "assets/svg/logo.svg",
          height: 30,
          width: 30,
          color: Colors.white,
        ),
        actions: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.cancel, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Consumer<ReferralProvider>(
        builder: (context, value, _) {
          return value.chatIndex == 0
              ? ChatboastHome()
              : isMobile
              ? value.chatPopupPage
                    ? Stack(children: [ChatUi(isMobile: isMobile)])
                    : ChatboatChat(isMobile: isMobile)
              : ChatboatChatFullScreen();
        },
      ),
      bottomNavigationBar: Consumer<ReferralProvider>(
        builder: (context, value, _) {
          return BottomNavigationBar(
            useLegacyColorScheme: false,
            enableFeedback: false,
            currentIndex: value.chatIndex,
            onTap: (index) => value.setIndex(index),
            backgroundColor: Colors.white,
            selectedItemColor: ColorsClass.primary,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined, size: 20),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.message_sharp, size: 20),
                label: "Chat",
              ),
            ],
          );
        },
      ),
    );
  }
}
