import 'package:flutter/material.dart';

/// Dropdown field
class RewardTypeDropdown extends StatelessWidget {
  final String? selectedValue;
  final void Function(String?) onChanged;
  final bool isUpdate;

  const RewardTypeDropdown({super.key, required this.selectedValue, required this.onChanged, this.isUpdate = false});

  @override
  Widget build(BuildContext context) {
    const rewardCashbackType = ["Flat", "Percentage"];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Reward Type*", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
          const SizedBox(height: 6),
          SizedBox(
            child: DropdownButtonFormField<String>(
              value: selectedValue != null && rewardCashbackType.contains(selectedValue) ? selectedValue : null,
              hint: const Text("Reward Type"),
              items: rewardCashbackType.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: "Reward Type",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
