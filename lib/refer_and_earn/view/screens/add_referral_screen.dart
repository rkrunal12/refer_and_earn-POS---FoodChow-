import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:refer_and_earn/refer_and_earn/view/widgets/send_all_button.dart';
import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../widgets/referral_list.dart';

class AddReferralScreen extends StatefulWidget {
  const AddReferralScreen({super.key});

  @override
  State<AddReferralScreen> createState() => _AddReferralScreenState();
}

class _AddReferralScreenState extends State<AddReferralScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ReferralProvider>(context, listen: false);
      if (provider.referrals.isEmpty) provider.addReferral();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final smallScreen = screenWidth <= 700;
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        title: Text(
          "Refer & Earn",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 20),
        ),
      ),
      body: Padding(
        padding: smallScreen
            ? const EdgeInsets.all(0)
            : const EdgeInsets.all(16.0),
        child: Card(
          elevation: 3,
          color: ColorsClass.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ReferralHeader(),
                const SizedBox(height: 8),
                const Divider(color: ColorsClass.deviderColor, thickness: 1),
                const SizedBox(height: 8),
                const Expanded(child: ReferralListAddReferral()),
                const SizedBox(height: 12),
                Consumer<ReferralProvider>(
                  builder: (context, value, child) {
                    if (value.referrals.length > 1) {
                      return const SendAllButton();
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Header with title and Add button
class ReferralHeader extends StatelessWidget {
  const ReferralHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReferralProvider>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;
    final smallScreen = screenWidth <= 550;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Your Referred Restaurants",
          style: GoogleFonts.poppins(
            fontSize: smallScreen ? 14 : 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        InkWell(
          onTap: provider.addReferral,
          child: Container(
            height: 40,
            width: 100,
            decoration: BoxDecoration(
              color: ColorsClass.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                "+ Add More",
                style: GoogleFonts.poppins(
                  fontSize: smallScreen ? 12 : 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
