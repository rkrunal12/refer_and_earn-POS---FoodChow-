import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../screens/cash_back.dart';
import '../widgets/common_widgets.dart';
import '../widgets/mobile_widgets.dart';

class MobileCashback extends StatefulWidget {
  const MobileCashback({super.key, required this.isMobile});
  final bool isMobile;
  @override
  State<MobileCashback> createState() => _MobileCashbackState();
}

class _MobileCashbackState extends State<MobileCashback> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReferralProvider>(
        context,
        listen: false,
      ).fetchCashbackData(false);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isMobile? Scaffold(
      appBar: const MobileAppBar(title: "Cashback"),
      body: Consumer<ReferralProvider>(
        builder: (context, value, child) {
          return Column(
            children: [
              /// Scrollable content
              SingleChildScrollView(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MobileToggleCard(
                      isEnable: value.isEnables,
                      onChanged: (val) {
                        value.setIsEnables(val);
                      },
                    ),
                    const SizedBox(height: 20),
                    MobileRulesCard(tabController: _tabController),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              /// Sticky Save Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                child: value.isCashbackAddLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GestureDetector(
                  child: CustomButton(
                    value: "Save",
                    color: ColorsClass.primary,
                  ),
                  onTap: () => CashBack.saveData(_tabController, context, true),
                ),
              ),
            ],
          );
        },
      ),
    )
        : Consumer<ReferralProvider>(
      builder: (context, value, child) {
        return Column(
          children: [
            /// Scrollable content
            SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MobileToggleCard(
                    isEnable: value.isEnables,
                    onChanged: (val) {
                      value.setIsEnables(val);
                    },
                  ),
                  const SizedBox(height: 20),
                  MobileRulesCard(tabController: _tabController),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            /// Sticky Save Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              child: value.isCashbackAddLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GestureDetector(
                child: CustomButton(
                  value: "Save",
                  color: ColorsClass.primary,
                ),
                onTap: () => CashBack.saveData(_tabController, context, false),
              ),
            ),
          ],
        );
      },
    );
  }
}
