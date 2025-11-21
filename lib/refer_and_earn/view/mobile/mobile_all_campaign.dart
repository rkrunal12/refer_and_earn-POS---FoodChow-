import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';


import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../widgets/common_widget.dart';
import '../widgets/mobile_widgets.dart';
import 'add_campaign_mobile.dart';

class MobileAllCampaign extends StatefulWidget {
  const MobileAllCampaign({super.key});

  @override
  State<MobileAllCampaign> createState() => _MobileAllCampaignState();
}

class _MobileAllCampaignState extends State<MobileAllCampaign> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReferralProvider>(context, listen: false).fetchData(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const MobileAppBar(title: "Refer and Earn"),
      body: Consumer<ReferralProvider>(
        builder: (context, value, _) {
          if (value.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = value.data;
          if (data.isEmpty) {
            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                  child: MobileHeader(
                    title: "Campaign Details",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const AddCampaignMobile(),
                        ),
                      );
                    },
                    mobileTitle: "+ Add Campaign",
                  ),
                ),
                Center(child: Text("No Data")),
              ],
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: data.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 10,
                  ),
                  child: MobileHeader(
                    title: "Campaign Details",
                    mobileTitle: "+ Add Campaign",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const AddCampaignMobile(),
                        ),
                      );
                    },
                  ),
                );
              }

              final campaign = data[index - 1];
              return MobileCampaignCardMobileAllCampaign(data: campaign);
            },
          );
        },
      ),
    );
  }
}

/// mobile header
class MobileHeader extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final String mobileTitle;
  const MobileHeader({
    super.key,
    required this.title,
    required this.onTap,
    required this.mobileTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
      ), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: title, 
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
          InkWell(
            onTap: onTap,
            child: Container(
              height: 36,
              width: 130,
              decoration: BoxDecoration(
                color: ColorsClass.primary,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Text(
                  mobileTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ColorsClass.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

