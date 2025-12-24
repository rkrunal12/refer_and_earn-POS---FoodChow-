import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:refer_and_earn/chatboat/controller/chat_boat_controller.dart';
import 'package:refer_and_earn/refer_and_earn/view/mobile/mobile_refer_screen.dart';
import 'package:refer_and_earn/refer_and_earn/view/screens/add_campaign.dart';
import 'package:refer_and_earn/refer_and_earn/view/screens/all_campaign.dart';
import 'package:refer_and_earn/refer_and_earn/view/screens/cash_back.dart';
import 'package:refer_and_earn/refer_and_earn/view/screens/restraurent_referal.dart';
import '../../../chatboat/view/pop up screen/chat_ui.dart';
import '../../../chatboat/view/pop up screen/chatbost_popup.dart';
import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../../controller/service/campaign_service.dart';
import '../../model/campaign_model.dart';
import '../widgets/content_container_image.dart';
class ReferScreen extends StatefulWidget {
  const ReferScreen({super.key});

  @override
  State<ReferScreen> createState() => _ReferScreenState();
}

class _ReferScreenState extends State<ReferScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<ReferralProvider>(context, listen: false);
      await provider.fetchData(false);
      if (!mounted) return;

      final now = DateTime.now();
      for (CampaignModel campaign in provider.data) {
        if (campaign.expiryEnableBool == true && campaign.statusStr == "1") {
          if (campaign.expiryType != "After Friend's First Order") {
            if (campaign.endDate != null) {
              final expiryDate = DateTime.tryParse(campaign.endDate!);
              if (expiryDate != null && now.isAfter(expiryDate)) {
                CampaignService.updateCampaigns(
                  CampaignModel(
                    campaignId: campaign.campaignId,
                    shopId: campaign.shopId,
                    campaignName: campaign.campaignName,
                    rewardType: campaign.rewardType,
                    customerReward: campaign.customerReward,
                    referrerReward: campaign.referrerReward,
                    expiryEnableInt: campaign.expiryEnableBool! ? 1 : 0,
                    minPurchase: campaign.minPurchase,
                    expiryType: campaign.expiryType,
                    fixedPeriodType: campaign.fixedPeriodType,
                    endDate: campaign.endDate,
                    notifyCustomerInt: campaign.notifyCustomerBool! ? 1 : 0,
                    statusInt: 0,
                  ),
                  context,
                  false,
                  isExpired: true,
                );
                // log(campaign.toJson().toString());
              }
            }
          }
        }
      }
    });
  }

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
                title: Text("Refer & Earn", style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 20)),
                actions: [
                  SvgPicture.asset("assets/svg/dish.svg"),
                  SizedBox(width: 10),
                  SvgPicture.asset("assets/svg/home.svg"),
                  SizedBox(width: 10),
                  SvgPicture.asset("assets/svg/wifi.svg"),
                  SizedBox(width: 10),
                  SvgPicture.asset("assets/svg/sound.svg"),
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
                                return buildSidebar(context, form.selectedIndex);
                              },
                            ),
                          ),
                        ),
                        Container(width: 2, height: double.infinity, color: ColorsClass.deviderColor),

                        /// Main content
                        Expanded(
                          flex: 4,
                          child: Consumer<ReferralProvider>(
                            builder: (context, form, _) {
                              return _buildContent(form.selectedIndex);
                            },
                          ),
                        ),
                      ],
                    )
                  : Consumer<ReferralProvider>(
                      builder: (context, form, _) {
                        return _buildContent(form.selectedIndex);
                      },
                    ),

              floatingActionButton: FloatingActionButton(
                shape: const CircleBorder(),
                tooltip: "Talk To AI",
                backgroundColor: ColorsClass.primary,
                onPressed: () {
                  Provider.of<ChatBoatProvider>(context, listen: false).setShowChatBoatPopup();
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => const ChatboatFullscreen(),
                  //   ),
                  // );
                },
                child: Image.asset("assets/images/charboat.png"),
              ),
            );
          },
        ),

        Consumer<ChatBoatProvider>(
          builder: (context, value, _) {
            if (!value.showChatBoatPopup) return const SizedBox();
            return value.chatPopupPage ? const ChatUi() : const ChatbostPopup();
          },
        ),
      ],
    );
  }
}

/// Side bar
Widget buildSidebar(BuildContext context, int selectedIndex) {
  final form = Provider.of<ReferralProvider>(context, listen: false);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 10),
      GestureDetector( 
        onTap: () => form.setSelectedIndex(0),
        child: ContentContainerImage(imagePath: "assets/svg/add.svg", title: "Add Campaign", isSelected: selectedIndex == 0),
      ),
      GestureDetector(
        onTap: () => form.setSelectedIndex(1),
        child: ContentContainerImage(imagePath: "assets/svg/all_campaign.svg", title: "All Campaign", isSelected: selectedIndex == 1),
      ),
      GestureDetector(
        onTap: () => form.setSelectedIndex(2),
        child: ContentContainerImage(imagePath: "assets/svg/cashback.svg", title: "Cash Back", isSelected: selectedIndex == 2),
      ),
      GestureDetector(
        onTap: () => form.setSelectedIndex(3),
        child: ContentContainerImage(imagePath: "assets/svg/restaurant.svg", title: "Restaurant Referral", isSelected: selectedIndex == 3),
      ),
      const Spacer(),
    ],
  );
}

Widget _buildContent(int selectedIndex) {
  return IndexedStack(index: selectedIndex, children: const [AddCampaign(), AllCampaign(), CashBack(), RestraurentReferal()]);
}
