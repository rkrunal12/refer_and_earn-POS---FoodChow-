import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:refer_and_earn/refer_and_earn/color_class.dart';
import '../../controller/chat_boat_controller.dart';
import '../pop up screen/chat_ui.dart';
import '../pop up screen/chatboat_chat.dart';
import '../widgets/chat_sidebaar.dart';
import 'chatboat_chat_fullscreen.dart';
import '../pop up screen/chatboat_home.dart';

class ChatboatFullscreen extends StatefulWidget {
  const ChatboatFullscreen({super.key});

  @override
  State<ChatboatFullscreen> createState() => _ChatboatFullscreenState();
}

class _ChatboatFullscreenState extends State<ChatboatFullscreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<ChatBoatProvider>(context, listen: false).init();
    });
  }

  void _closeDrawer() {
    if (_scaffoldKey.currentState != null &&
        _scaffoldKey.currentState!.isDrawerOpen) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 550;
    final bool useSidebar = MediaQuery.of(context).size.width >= 850;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: Consumer<ChatBoatProvider>(
          builder: (context, value, child) {
            if (value.chatPopupPage && isMobile) {
              return IconButton(
                onPressed: value.backToChatListScreen,
                icon: const Icon(
                  Icons.arrow_back_ios_new_outlined,
                  color: Colors.white,
                ),
              );
            } else if (isMobile) {
              return const SizedBox.shrink();
            } else if (!useSidebar) {
              return IconButton(
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                icon: const Icon(Icons.menu, color: Colors.white),
              );
            } else {
              return const SizedBox.shrink();
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
      body: Consumer<ChatBoatProvider>(
        builder: (context, value, _) {
          return value.chatBoatPupupIndex == 0
              ? const ChatboastHome()
              : isMobile
              ? value.chatPopupPage
                    ? Stack(children: [ChatUi(isMobile: isMobile)])
                    : ChatboatChat(isMobile: isMobile)
              : const ChatboatChatFullScreen();
        },
      ),
      drawer: !isMobile
          ? Drawer(
              backgroundColor: Colors.white,
              width: 350,
              child: ChatSideBar(onItemTap: _closeDrawer),
            )
          : null,
      bottomNavigationBar: Consumer<ChatBoatProvider>(
        builder: (context, value, _) {
          return BottomNavigationBar(
            useLegacyColorScheme: false,
            enableFeedback: false,
            currentIndex: value.chatBoatPupupIndex,
            onTap: (index) => value.setChatBoatPopupIndex(index),
            backgroundColor: Colors.white,
            selectedItemColor: ColorsClass.primary,
            unselectedItemColor: Colors.grey,
            items: [
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  "assets/svg/home_new.svg",
                  height: 25,
                  width: 25,
                  color: value.chatBoatPupupIndex == 0
                      ? ColorsClass.primary
                      : Colors.grey,
                ),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/images/chat.png",
                  height: 25,
                  width: 25,
                  color: value.chatBoatPupupIndex == 1
                      ? ColorsClass.primary
                      : Colors.grey,
                ),
                label: "Chat",
              ),
            ],
          );
        },
      ),
    );
  }
}
