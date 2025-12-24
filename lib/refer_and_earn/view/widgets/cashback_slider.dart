import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refer_and_earn/refer_and_earn/color_class.dart';

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
    final ValueNotifier<double> localValue = ValueNotifier<double>(
      currentValue,
    );

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
                  ),
                ),
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
                localValue.value = val;
              },
              onChangeEnd: (val) {
                onChanged(val);
              },
            );
          },
        ),
      ],
    );
  }
}
