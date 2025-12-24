import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

/// Generic text field widget
class TextFieldColumn extends StatelessWidget {
  final String hint;
  final String label;
  final TextEditingController controller;
  final TextInputType type;
  final bool? isPhone;
  final bool? mobile;
  final ValueChanged<String?>? onIsoCodeChanged;
  final bool isTag;

  const TextFieldColumn({
    super.key,
    this.onIsoCodeChanged,
    required this.hint,
    required this.label,
    required this.controller,
    required this.type,
    this.isPhone,
    this.mobile,
    this.isTag = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isTag ? Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)) : SizedBox(),
          const SizedBox(height: 6),
          if (isPhone ?? false) ...[
            InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber number) {
                onIsoCodeChanged?.call(number.isoCode);
              },
              spaceBetweenSelectorAndTextField: 1,
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.DROPDOWN,
                showFlags: true,
                useBottomSheetSafeArea: true,
                leadingPadding: 0,
                trailingSpace: true,
              ),
              autoValidateMode: AutovalidateMode.disabled,
              textFieldController: controller,
              formatInput: true,
              initialValue: PhoneNumber(isoCode: "IN"),
              inputDecoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                counterText: "",
              ),
              keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
            ),
          ] else
            TextField(
              controller: controller,
              keyboardType: type,
              decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
        ],
      ),
    );
  }
}
