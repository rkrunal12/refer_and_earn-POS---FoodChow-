import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:refer_and_earn/refer_and_earn/view/screens/add_campaign.dart';
import 'package:refer_and_earn/refer_and_earn/view/screens/all_campaign.dart';
import 'package:refer_and_earn/refer_and_earn/view/screens/cash_back.dart';
import 'package:toastification/toastification.dart';
import '../../color_class.dart';
import '../../controller/provider/refer_provider.dart';
import '../screens/restraurent_referal.dart';

/// Show a Snack bar using Fluttertoast
class CustomeToast {
  static void showSuccess(String message) {
    final notification = Toastification().show(
      title: Text(message),
      icon: const Icon(Icons.notifications_active),
      autoCloseDuration: const Duration(seconds: 3),
      style: ToastificationStyle.flatColored,
      primaryColor: ColorsClass.primary,
      alignment: Alignment.topRight,
    );
    toastification.dismiss(notification);
  }

  static void showError(String message) {
    final notification = Toastification().show(
      title: Text(message),
      icon: const Icon(Icons.error),
      autoCloseDuration: const Duration(seconds: 3),
      style: ToastificationStyle.flatColored,
      primaryColor: Colors.red,
      alignment: Alignment.topRight,
    );
    toastification.dismiss(notification);
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
          isTag
              ? Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                )
              : SizedBox(),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                counterText: "",
              ),
              keyboardType: const TextInputType.numberWithOptions(
                signed: false,
                decimal: false,
              ),
            ),
          ] else
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
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
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
                  : null,
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

//content container
class ContentContainer extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;

  const ContentContainer({
    super.key,
    required this.icon,
    required this.title,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? ColorsClass.primary : ColorsClass.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isSelected ? ColorsClass.white : ColorsClass.blackColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isSelected ? ColorsClass.white : ColorsClass.blackColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Container with image and text
class ContentContainerImage extends StatelessWidget {
  final String imagePath;
  final String title;
  final bool isSelected;

  const ContentContainerImage({
    super.key,
    required this.imagePath,
    required this.title,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? ColorsClass.primary : ColorsClass.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            height: 30,
            child: SvgPicture.asset(
              imagePath,
              color: isSelected ? ColorsClass.white : ColorsClass.blackColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isSelected ? ColorsClass.white : ColorsClass.blackColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// IndexedStack content
class BuildContent extends StatelessWidget {
  final int selectedIndex;

  const BuildContent({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: selectedIndex,
      children: const [
        AddCampaign(),
        AllCampaign(),
        CashBack(),
        RestraurentReferal(),
      ],
    );
  }
}

/// Side bar
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
          imagePath: "assets/svg/cashback.svg",
          title: "Cash Back",
          isSelected: selectedIndex == 2,
        ),
      ),
      GestureDetector(
        onTap: () => form.setSelectedIndex(3),
        child: ContentContainerImage(
          imagePath: "assets/svg/restaurant.svg",
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
        borderRadius: BorderRadiusGeometry.all(Radius.circular(6)),
      ),
      child: Center(
        child: CustomText(
          text: value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: ColorsClass.white,
          ),
        ),
      ),
    );
  }
}

/// Custom Radio List
class CustomRadioListTile extends StatelessWidget {
  final String title;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

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
      title: CustomText(
        text: title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      ),
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
    return Checkbox(value: value, onChanged: onChanged);
  }
}
