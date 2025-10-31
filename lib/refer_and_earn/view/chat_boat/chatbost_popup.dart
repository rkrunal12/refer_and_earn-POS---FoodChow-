import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:refer_and_earn/refer_and_earn/color_class.dart';
import 'package:refer_and_earn/refer_and_earn/controller/provider/refer_provider.dart';
import 'package:refer_and_earn/refer_and_earn/view/chat_boat/chatboat_chat.dart';
import 'package:refer_and_earn/refer_and_earn/view/chat_boat/chatboat_home.dart';

class ChatbostPopup extends StatefulWidget {
  const ChatbostPopup({super.key});

  @override
  State<ChatbostPopup> createState() => _ChatbostPopupState();
}

class _ChatbostPopupState extends State<ChatbostPopup> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<ReferralProvider>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReferralProvider>(context, listen: false);

    return Positioned(
      bottom: 80,
      right: 20,
      child: SizedBox(
        width: provider.isChatUiExpanded ? 600 : 400,
        height: 650,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 14),
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
                    SvgPicture.asset(
                      "assets/svg/logo.svg",
                      height: 30,
                      width: 30,
                      color: Colors.white,
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => provider.setPopUp(),
                      icon: const Icon(
                        Icons.cancel,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Consumer<ReferralProvider>(
                  builder: (context, value, _) {
                    return value.chatIndex == 0
                        ? ChatboastHome()
                        : ChatboatChat();
                  },
                ),
              ),

              Consumer<ReferralProvider>(
                builder: (context, value, _) {
                  return BottomNavigationBar(
                    useLegacyColorScheme: false,
                    enableFeedback: false,
                    currentIndex: value.chatIndex,
                    onTap: (index) => provider.setIndex(index),
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
            ],
          ),
        ),
      ),
    );
  }
}
