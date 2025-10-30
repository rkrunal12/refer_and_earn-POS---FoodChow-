import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import 'common_widget.dart';

/// Build slider for cashback
class CashbackSlider extends StatelessWidget {
  final double currentValue;
  final double maxValue;
  final String labelPrefix;
  final ValueChanged<double> onChanged;

  const CashbackSlider({
    super.key,
    required this.currentValue,
    required this.maxValue,
    required this.labelPrefix,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<double> localValue = ValueNotifier<double>(currentValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder<double>(
          valueListenable: localValue,
          builder: (context, value, _) {
            return Row(
              children: [
                Text(labelPrefix),
                const SizedBox(width: 2),
                Text(
                  maxValue == 50 ? "${value.toInt()}%" : "₹${value.toInt()}",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: ColorsClass.primary,
                ),)
              ],
            );
          },
        ),
        ValueListenableBuilder<double>(
          valueListenable: localValue,
          builder: (context, value, _) {
            return Slider(
              min: 0,
              divisions: 5,
              max: maxValue,
              value: value.clamp(0, maxValue),
              onChanged: (val) {
                localValue.value = val; // update local UI instantly
              },
              onChangeEnd: (val) {
                onChanged(val); // only commit to provider/SPI at end
              },
            );
          },
        ),
      ],
    );
  }
}


/// Cashback rules card with tabs
class CashbackRulesCard extends StatelessWidget {
  final TabController tabController;

  const CashbackRulesCard({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              "Cash Back Rules",
              style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w500),
            ),
          ),
          TabBar(
            controller: tabController,
            isScrollable: true,
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.black,
            indicatorColor: Colors.teal,
            labelPadding: const EdgeInsets.symmetric(horizontal: 20),
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
                  if (tabController.index != newIndex &&
                      !tabController.indexIsChanging &&
                      newIndex < tabController.length) {
                    tabController.index = newIndex;
                  }
                });

                return TabBarView(
                  controller: tabController,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: CashbackSlider(
                        currentValue: data.percentageDiscount,
                        maxValue: 50,
                        labelPrefix: "Allow up to",
                        onChanged: data.setPercentageDiscount,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
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

/// Toggle card with switch
class ToggleCard extends StatelessWidget {
  final bool isEnable;
  final ValueChanged<bool> onChanged;

  const ToggleCard({
    super.key,
    required this.isEnable,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        title: CustomText(
          text: "Authorised FoodChow Cash",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: CustomText(
          text: "Enable this to start accepting FoodChow Cash",
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              text: isEnable ? "Enabled" : "Disabled",
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 5),
            Switch(value: isEnable, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
