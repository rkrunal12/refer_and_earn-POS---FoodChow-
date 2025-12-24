
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../color_class.dart';

class CampaignDetailedCampaignInfo extends StatelessWidget {
  final String title;
  final String number;

  const CampaignDetailedCampaignInfo({super.key, required this.title, required this.number});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Card(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                child: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14)),
              ),
              const SizedBox(height: 10),
              Text(
                number,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 29, color: ColorsClass.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
