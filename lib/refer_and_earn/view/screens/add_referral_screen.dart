import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../widgets/referral_widget.dart';

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
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        title: const Text(
          "Refer & Earn",
          style: TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                // Static header and divider
                const ReferralHeader(),
                const SizedBox(height: 8),
                const Divider(color: ColorsClass.deviderColor, thickness: 1),
                const SizedBox(height: 8),

                // Expandable scrollable list handled internally by ReferralList
                const Expanded(
                  child: ReferralList(isMobile: false,),
                ),

                const SizedBox(height: 12),

                // Conditional SendAllButton
                Consumer<ReferralProvider>(
                  builder: (context, value, child) {
                    if (value.referrals.length > 1) {
                      return const SendAllButton(isMobile: false,);
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
