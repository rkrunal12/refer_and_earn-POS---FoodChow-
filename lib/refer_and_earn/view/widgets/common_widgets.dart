import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import '../../../main.dart';
import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import 'campaign_widgets.dart';

/// Show a Snack bar using Fluttertoast
class CustomSnackBar {
  static void show(String message, bool isMobile) {
    final context = navigatorKey.currentContext!;
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 2),
      title: Text(
        message,
        style: const TextStyle(fontSize: 16),
      ),
      description: SizedBox(
        width: MediaQuery.of(context).size.width,
      ),
      alignment: isMobile ? Alignment.topCenter :Alignment.bottomCenter,
      direction: TextDirection.ltr,
      animationDuration: const Duration(milliseconds: 300),
      animationBuilder: (context, animation, alignment, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: isMobile ? const Offset(2.0, 0.0) :const Offset(4.0, 0.0),
            end: const Offset(0.0, 0.0),
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
              reverseCurve: Curves.easeIn,
            ),
          ),
          child: child,
        );
      },
      showIcon: false,
      primaryColor: ColorsClass.primary.withOpacity(0.5),
      backgroundColor: Color(0x0fe6f6f5),
      foregroundColor: ColorsClass.blackColor,
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: ColorsClass.primary,
        width: 3,
      ),
      showProgressBar: false,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
    );
  }
}

/// Custom text widget
class CustomText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const CustomText({super.key, required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: style);
  }
}

/// Custom fitted text
class CustomFittedText extends StatelessWidget {
  final String text;
  const CustomFittedText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "",
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      softWrap: true,
      maxLines: null,
    );
  }
}

/// Generic text field widget
class TextFieldColumn extends StatelessWidget {
  final String hint;
  final String label;
  final TextEditingController controller;
  final TextInputType type;
  final bool? isPhone;
  final bool? mobile;
  final ValueChanged<String?>? onIsoCodeChanged;

  const TextFieldColumn({
    super.key,
    this.onIsoCodeChanged,
    required this.hint,
    required this.label,
    required this.controller,
    required this.type,
    this.isPhone,
    this.mobile
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 6),
          if(isPhone ?? false)...[
            InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber number) {
                onIsoCodeChanged?.call(number.isoCode);
              },
              spaceBetweenSelectorAndTextField:1,
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.DROPDOWN,
                showFlags: true,
                useBottomSheetSafeArea: true,
                leadingPadding: 0,
                trailingSpace: true
              ),
              autoValidateMode: AutovalidateMode.disabled,
              textFieldController: controller,
              formatInput: true,
              initialValue: PhoneNumber(isoCode: "IN"),
              inputDecoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                counterText: "",
              ),
              keyboardType: const TextInputType.numberWithOptions(
                signed: false,
                decimal: false,
              ),
            )

            ,]
          else
            TextField(
              controller: controller,
              keyboardType: type,
              decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Dropdown field
class RewardTypeDropdown extends StatelessWidget {
  final String? selectedValue;
  final void Function(String?) onChanged;
  final bool isUpdate;

  const RewardTypeDropdown({
    super.key,
    required this.selectedValue,
    required this.onChanged,
    this.isUpdate = false,
  });

  @override
  Widget build(BuildContext context) {
    const rewardCashbackType = ["Flat", "Percentage"];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Reward Type*",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 6),
          SizedBox(
            child: DropdownButtonFormField<String>(
              value:
              selectedValue != null &&
                  rewardCashbackType.contains(selectedValue)
                  ? selectedValue
                  : null, // safely handle null
              hint: const Text("Reward Type"),
              items: rewardCashbackType
                  .map(
                    (value) =>
                    DropdownMenuItem(value: value, child: Text(value)),
              )
                  .toList(),
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: "Reward Type",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Size bar
Widget buildSidebar(BuildContext context, int selectedIndex) {
  final form = Provider.of<ReferralProvider>(context, listen: false);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 10),
      GestureDetector(
        onTap: () => form.setSelectedIndex(0),
        child: ContentContainer(
          icon: Icons.add_circle,
          title: "Add Campaign",
          isSelected: selectedIndex == 0,
        ),
      ),
      GestureDetector(
        onTap: () => form.setSelectedIndex(1),
        child: ContentContainer(
          icon: Icons.list,
          title: "All Campaign",
          isSelected: selectedIndex == 1,
        ),
      ),
      GestureDetector(
        onTap: () => form.setSelectedIndex(2),
        child: ContentContainerImage(
          imagePath: "assets/images/refer_and_earn/cashback.png",
          title: "Cash Back",
          isSelected: selectedIndex == 2,
        ),
      ),
      GestureDetector(
        onTap: () => form.setSelectedIndex(3),
        child: ContentContainerImage(
          imagePath: "assets/images/refer_and_earn/restaurant.png",
          title: "Restaurant Referral",
          isSelected: selectedIndex == 3,
        ),
      ),
      const Spacer(),
    ],
  );
}

/// Custom button
class CustomButton extends StatelessWidget {
  final String value;
  final Color color;
  const CustomButton({super.key, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 200,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadiusGeometry.all(Radius.circular(6))
      ),
      child: Center(child: CustomText(text: value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: ColorsClass.white)),),
    );
  }
}

/// Custom Radio List
class CustomRadioListTile extends StatelessWidget {
  final String title;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged; // Proper type for onChanged callback

  const CustomRadioListTile({
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });


  @override
  Widget build(BuildContext context) {
    return RadioListTile(
        value: value,
      title: CustomText(text: title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }
}

/// Custom Checkbox
class CustomCheckBox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const CustomCheckBox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: value,
      onChanged: onChanged,
    );
  }
}


