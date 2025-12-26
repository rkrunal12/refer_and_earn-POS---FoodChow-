import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../screens/cash_back.dart';
import '../widgets/cashback_slider.dart';
import '../widgets/custom_button.dart';
import '../widgets/mobile_app_baar.dart';

class MobileCashback extends StatefulWidget {
  const MobileCashback({super.key});
  @override
  State<MobileCashback> createState() => _MobileCashbackState();
}

class _MobileCashbackState extends State<MobileCashback> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final minimumAmountController = TextEditingController();
  final termsAndConditionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<ReferralProvider>(context, listen: false);
      if (provider.allCashback == null) {
        await provider.fetchCashbackData(false);
      }
      if (!mounted) return;
      minimumAmountController.text = provider.minimumOrderAmount.toString();
      termsAndConditionController.text = provider.termsAndConditions;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MobileAppBar(title: "Cashback"),
      body: SafeArea(
        child: Consumer<ReferralProvider>(
          builder: (context, value, child) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MobileToggleCardCashback(
                              isEnable: value.isEnables,
                              onChanged: (val) {
                                value.setIsEnables(val);
                              },
                            ),
                            ConditionalWidgerEditor(
                              controller: minimumAmountController,
                              header: "Minimum Order Amount",
                              hint: "Enter Minimum Amount",
                              maxLength: 6,
                              inputType: TextInputType.number,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return "Enter Amount";
                                if (int.tryParse(val.trim()) == null) return "Enter valid number";
                                return null;
                              },
                            ),
                            MobileRulesCardCashback(tabController: _tabController),
                            ConditionalWidgerEditor(
                              header: "Terms & Condition",
                              hint: "Enter Terms & Condition",
                              controller: termsAndConditionController,
                              inputType: TextInputType.multiline,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return "Enter Terms";
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8.0),
                      child: value.isCashbackAddLoading
                          ? const Center(child: CircularProgressIndicator())
                          : CustomButton(
                              value: "Save",
                              color: ColorsClass.primary,
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  value.setMinimumOrderAmt(int.parse(minimumAmountController.text));
                                  value.setTermsAndConditions(termsAndConditionController.text);
                                  CashBack.saveData(_tabController, context);
                                }
                              },
                            ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MobileToggleCardCashback extends StatelessWidget {
  final bool isEnable;
  final ValueChanged<bool> onChanged;

  const MobileToggleCardCashback({super.key, required this.isEnable, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("Authorised FoodChow Cash", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
      subtitle: Text(
        "Enable this to start accepting FoodChow Cash",
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.grey),
      ),
      trailing: Switch(value: isEnable, onChanged: onChanged),
    );
  }
}

/// Mobile cashback rules with slider
class MobileRulesCardCashback extends StatelessWidget {
  final TabController tabController;

  const MobileRulesCardCashback({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text("Cash Back Rules", style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w500)),
          ),
          TabBar(
            controller: tabController,
            isScrollable: false,
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.black,
            indicatorColor: Colors.teal,
            labelPadding: const EdgeInsets.only(left: 5),
            tabs: const [
              Tab(text: "Percentage Discount"),
              Tab(text: "Fixed Amount"),
            ],
          ),
          SizedBox(
            height: 100,
            child: Consumer<ReferralProvider>(
              builder: (context, data, _) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final newIndex = data.rewardCashbackType == "Flat" ? 1 : 0;
                  if (tabController.index != newIndex && !tabController.indexIsChanging && newIndex < tabController.length) {
                    tabController.index = newIndex;
                  }
                });

                return TabBarView(
                  controller: tabController,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: CashbackSlider(
                        currentValue: data.percentageDiscount,
                        maxValue: 50,
                        labelPrefix: "Allow up to",
                        onChanged: data.setPercentageDiscount,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: CashbackSlider(
                        currentValue: data.fixedDiscount,
                        maxValue: 500,
                        labelPrefix: "Allow fixed amount of",
                        onChanged: data.setFixedDiscount,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
