import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../../model/cashback_model.dart';
import '../widgets/cashback_rules_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/text_field_column.dart';

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
      cashbackValue: (tab.index == 0 ? provider.percentageDiscount : provider.fixedDiscount).toInt(),
      minimumOrderAmount: provider.minimumOrderAmount.toInt(),
      termsAndConditions: provider.termsAndConditions,
    );

    await provider.saveCashback(model);
  }

  @override
  State<CashBack> createState() => _CashBackState();
}

class _CashBackState extends State<CashBack> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final minimumAmountController = TextEditingController();
  final termsAndConditionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final value = Provider.of<ReferralProvider>(context, listen: false);
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (value.allCashback == null) {
        await value.fetchCashbackData(false);
      }
      if (!mounted) return;
      minimumAmountController.text = value.minimumOrderAmount.toString();
      termsAndConditionController.text = value.termsAndConditions;
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Cash Back", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                      Card(
                        color: ColorsClass.white,
                        elevation: 2,
                        child: ListTile(
                          title: Text("Authorised FoodChow Cash", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            "Enable this to start accepting FoodChow Cash",
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.grey),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(value.isEnables ? "Enabled" : "Disabled", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                              const SizedBox(width: 5),
                              Switch(
                                value: value.isEnables,
                                onChanged: (val) {
                                  value.setIsEnables(val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      ConditionalWidgerEditor(
                        controller: minimumAmountController,
                        header: "Minimum Order Amont",
                        hint: "Enter Minimum Amount",
                        maxLength: 6,
                        inputType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return "Enter Amount";
                          if (int.tryParse(val.trim()) == null) return "Enter valid number";
                          return null;
                        },
                      ),

                      SizedBox(
                        width: double.infinity,
                        child: CashbackRulesCard(tabController: _tabController),
                      ),

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
                      SizedBox(
                        height: 50,
                        width: 200,
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
                    ],
                  ),
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
    this.inputType = TextInputType.text,
    this.onChanged,
    this.validator,
    this.maxLength,
  });
  final String header;
  final String hint;
  final TextEditingController controller;
  final TextInputType inputType;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(header, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
          SizedBox(height: 0),
          TextFieldColumn(
            controller: controller,
            hint: hint,
            label: header,
            type: inputType,
            isTag: false,
            validator: validator,
            maxLength: maxLength,
          ),
        ],
      ),
    );
  }
}
