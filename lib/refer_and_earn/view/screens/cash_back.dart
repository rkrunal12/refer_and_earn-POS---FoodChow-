import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:refer_and_earn/refer_and_earn/view/mobile/mobile_cashback.dart';
import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../../model/cashback_model.dart';
import '../widgets/cashback_widgets.dart';
import '../widgets/common_widget.dart';

class CashBack extends StatefulWidget {
  const CashBack({super.key});

  static Future<void> saveData(TabController tab, BuildContext context) async {
    final provider = Provider.of<ReferralProvider>(context, listen: false);
    final existingData = provider.allCashback;

    final model = CashbackModel(
      cashbackId: existingData?.cashbackId ?? 1,
      shopId: existingData?.shopId ?? "7866",
      cashbackEnable: provider.isEnables ? 1 : 0,
      cashbackType: tab.index == 0 ? "Discount" : "Flat",
      cashbackValue:
          (tab.index == 0
                  ? provider.percentageDiscount
                  : provider.fixedDiscount)
              .toInt(),
    );

    await provider.saveCashback(model);
  }

  @override
  State<CashBack> createState() => _CashBackState();
}

class _CashBackState extends State<CashBack>
    with SingleTickerProviderStateMixin {
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 550;
    return SingleChildScrollView(
      child: isMobile
          ? MobileCashback(isMobile: false)
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 2,
                child: Consumer<ReferralProvider>(
                  builder: (context, value, child) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Cash Back",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),

                          /// Enable/Disable toggle
                          ToggleCard(
                            isEnable: value.isEnables,
                            onChanged: (val) {
                              value.setIsEnables(
                                val,
                              ); // updates provider instantly
                            },
                          ),

                          const SizedBox(height: 20),

                          /// Cashback rules
                          SizedBox(
                            width: double.infinity,
                            child: CashbackRulesCard(
                              tabController: _tabController,
                            ),
                          ),
                          const SizedBox(height: 20),

                          SizedBox(
                            height: 50,
                            width: 200,
                            child: value.isCashbackAddLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : GestureDetector(
                                    child: const CustomButton(
                                      value: "Save",
                                      color: ColorsClass.primary,
                                    ),
                                    onTap: () {
                                      CashBack.saveData(
                                        _tabController,
                                        context,
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}
