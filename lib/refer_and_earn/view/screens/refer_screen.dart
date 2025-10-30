import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:refer_and_earn/refer_and_earn/view/mobile/mobile_refer_screen.dart';
import 'package:refer_and_earn/refer_and_earn/view/screens/chat_boat/chat_ui.dart';
import 'package:refer_and_earn/refer_and_earn/view/screens/chat_boat/chatbost_popup.dart';
import 'package:refer_and_earn/refer_and_earn/view/widgets/campaign_widgets.dart';
import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../widgets/common_widget.dart';
import 'chat_boat/chatboat_fullscree.dart';

class ReferScreen extends StatelessWidget {
  const ReferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final bool useSidebar = constraints.maxWidth >= 900;
            final bool mobileLayout = constraints.maxWidth < 550;

            if (mobileLayout) {
              return const MobileReferenceScreen();
            }

            return Scaffold(
              appBar: AppBar(
                elevation: 2,
                title: Text(
                  "Refer & Earn",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                ),
                actions: [
                  ImageAssets(path: "assets/svg/dish.svg"),
                  SizedBox(width: 10),
                  ImageAssets(path: "assets/svg/home.svg"),
                  SizedBox(width: 10),
                  ImageAssets(path: "assets/svg/wifi.svg"),
                  SizedBox(width: 10),
                  ImageAssets(path: "assets/svg/sound.svg"),
                  SizedBox(width: 10),
                ],
                backgroundColor: Colors.white,
              ),

              drawer: useSidebar
                  ? null
                  : Drawer(
                      child: SafeArea(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Consumer<ReferralProvider>(
                            builder: (context, form, _) {
                              return buildSidebar(context, form.selectedIndex);
                            },
                          ),
                        ),
                      ),
                    ),

              body: useSidebar
                  ? Row(
                      children: [
                        /// Side bar
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: double.infinity,
                            child: Consumer<ReferralProvider>(
                              builder: (context, form, _) {
                                return buildSidebar(
                                  context,
                                  form.selectedIndex,
                                );
                              },
                            ),
                          ),
                        ),
                        Container(
                          width: 2,
                          height: double.infinity,
                          color: ColorsClass.deviderColor,
                        ),

                        /// Main content
                        Expanded(
                          flex: 4,
                          child: Consumer<ReferralProvider>(
                            builder: (context, form, _) {
                              return BuildContent(
                                selectedIndex: form.selectedIndex,
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : Consumer<ReferralProvider>(
                      builder: (context, form, _) {
                        return BuildContent(selectedIndex: form.selectedIndex);
                      },
                    ),

              floatingActionButton: FloatingActionButton(
                shape: const CircleBorder(),
                backgroundColor: ColorsClass.primary,
                onPressed: () {
                  // Provider.of<ReferralProvider>(
                  //   context,
                  //   listen: false,
                  // ).setPopUp();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatboatFullscreen(),
                    ),
                  );
                },
                child: Image.asset("assets/images/charboat.png"),
              ),
            );
          },
        ),

        /// Chat Popup Layer
        Consumer<ReferralProvider>(
          builder: (context, value, _) {
            if (!value.showPopUp) return const SizedBox();

            return Stack(
              children: [
                value.chatPopupPage ? const ChatUi() : const ChatbostPopup(),
              ],
            );
          },
        ),
      ],
    );
  }
}
