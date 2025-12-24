import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../color_class.dart';

/// Custom appBar
class MobileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const MobileAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600)),
      backgroundColor: ColorsClass.white,
      actions: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/images/user.png", height: 24, width: 24),
            const SizedBox(width: 10),
            Text("Admin", style: GoogleFonts.poppins(fontSize: 17)),
            const SizedBox(width: 10),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
