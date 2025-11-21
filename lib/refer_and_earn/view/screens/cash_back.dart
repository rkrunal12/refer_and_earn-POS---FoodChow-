import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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

    log(model.toJson().toString());
    log("minimum Price : ${provider.minimumPrice}");
    log("terms : ${provider.termsCodition}");
    await provider.saveCashback(model);
  }

  @override
  State<CashBack> createState() => _CashBackState();
}

class _CashBackState extends State<CashBack>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final minimumAmountController = TextEditingController();
  final termsAndConditionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final value = Provider.of<ReferralProvider>(context, listen: false);
    minimumAmountController.text = value.minimumPrice.toString();
    termsAndConditionController.text = value.termsCodition;
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      value.fetchCashbackData(false);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    minimumAmountController.dispose();
    termsAndConditionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: ColorsClass.white,
          elevation: 2,
          child: Consumer<ReferralProvider>(
            builder: (context, value, child) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  spacing: 10,
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
                    ToggleCard(
                      isEnable: value.isEnables,
                      onChanged: (val) {
                        value.setIsEnables(val);
                      },
                    ),

                    const SizedBox(height: 20),

                    ConditionalWidgerEditor(
                      controller: minimumAmountController,
                      header: "Minimum Order Amont",
                      hint: "Enter Minimum Amount",
                    ),

                    SizedBox(
                      width: double.infinity,
                      child: CashbackRulesCard(tabController: _tabController),
                    ),

                    ConditionalWidgerEditor(
                      header: "Terms & Condition",
                      hint: "Enter Terms & Condition",
                      controller: termsAndConditionController,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 50,
                      width: 200,
                      child: value.isCashbackAddLoading
                          ? const Center(child: CircularProgressIndicator())
                          : GestureDetector(
                              child: const CustomButton(
                                value: "Save",
                                color: ColorsClass.primary,
                              ),
                              onTap: () {
                                value.setMimimumPriceEdiitngEnable(
                                  double.parse(minimumAmountController.text),
                                );
                                value.setTermsAndConditions(
                                  termsAndConditionController.text,
                                );
                                CashBack.saveData(_tabController, context);
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

class ConditionalWidgerEditor extends StatelessWidget {
  const ConditionalWidgerEditor({
    super.key,
    required this.header,
    required this.hint,
    required this.controller,
    this.onChanged,
  });
  final String header;
  final String hint;
  final TextEditingController controller;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            header,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0),
          TextFieldColumn(
            controller: controller,
            hint: hint,
            label: header,
            type: TextInputType.number,
            isTag: false,
          ),
        ],
      ),
    );
  }
}
