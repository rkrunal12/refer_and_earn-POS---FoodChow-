import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:refer_and_earn/refer_and_earn/view/mobile/mobile_refer_screen.dart';
import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../widgets/campaign_widgets.dart';
import '../widgets/common_widgets.dart';

class ReferScreen extends StatefulWidget {
  const ReferScreen({super.key});

  @override
  State<ReferScreen> createState() => _ReferScreenState();
}

class _ReferScreenState extends State<ReferScreen> {
  /// Pre-cache images to reduce latency at runtime
  final List<String> _imageAssets = [
    "assets/images/refer_and_earn/dish.png",
    "assets/images/refer_and_earn/home.png",
    "assets/images/refer_and_earn/wifi.png",
    "assets/images/refer_and_earn/sound.png",
    "assets/images/refer_and_earn/cashback.png",
    "assets/images/refer_and_earn/restaurant.png",
  ];

  bool _imagesPrecached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagesPrecached) {
      for (var path in _imageAssets) {
        precacheImage(AssetImage(path), context);
      }
      _imagesPrecached = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool useSidebar = constraints.maxWidth >= 900;
        final bool mobileLayout = constraints.maxWidth < 550;
        return mobileLayout
            ? const MobileReferenceScreen()
            : Scaffold(
                appBar: AppBar(
                  elevation: 2,
                  title: const Text(
                    "Refer & Earn",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                  actions: const [
                    ImageAssets("assets/images/refer_and_earn/dish.png"),
                    SizedBox(width: 10),
                    ImageAssets("assets/images/refer_and_earn/home.png"),
                    SizedBox(width: 10),
                    ImageAssets("assets/images/refer_and_earn/wifi.png"),
                    SizedBox(width: 10),
                    ImageAssets("assets/images/refer_and_earn/sound.png"),
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
                                return buildSidebar(
                                  context,
                                  form.selectedIndex,
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                body: useSidebar
                    ? Row(
                        children: [
                          /// Side bar navigation
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

                          ///main screen
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
                          return BuildContent(
                            selectedIndex: form.selectedIndex,
                          );
                        },
                      ),
              );
      },
    );
  }
}
