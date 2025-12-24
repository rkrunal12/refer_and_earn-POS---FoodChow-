import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../color_class.dart';

/// Toggle card with switch
class ToggleCard extends StatelessWidget {
  final bool isEnable;
  final ValueChanged<bool> onChanged;

  const ToggleCard({super.key, required this.isEnable, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ColorsClass.white,
      elevation: 2,
      child: ListTile(
        title: Text(
          "Authorised FoodChow Cash",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          "Enable this to start accepting FoodChow Cash",
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isEnable ? "Enabled" : "Disabled", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(width: 5),
            Switch(value: isEnable, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
