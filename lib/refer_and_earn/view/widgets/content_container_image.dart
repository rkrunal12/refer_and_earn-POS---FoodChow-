import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../color_class.dart';

/// Container with image and text
class ContentContainerImage extends StatelessWidget {
  final String imagePath;
  final String title;
  final bool isSelected;

  const ContentContainerImage({super.key, required this.imagePath, required this.title, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? ColorsClass.primary : ColorsClass.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Row(
        children: [
          SizedBox(height: 30, child: SvgPicture.asset(imagePath, color: isSelected ? ColorsClass.white : ColorsClass.blackColor)),
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
