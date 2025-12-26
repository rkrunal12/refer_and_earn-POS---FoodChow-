import 'package:flutter/material.dart';
import '../../color_class.dart';

/// Custom button
class CustomButton extends StatelessWidget {
  final String value;
  final Color color;
  final VoidCallback onTap;
  final double? width;
  final double? height;

  const CustomButton({super.key, required this.value, required this.color, required this.onTap, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height ?? 50,
        width: width ?? 200,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadiusGeometry.all(Radius.circular(6))),
        child: Center(
          child: Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: ColorsClass.white),
          ),
        ),
      ),
    );
  }
}
