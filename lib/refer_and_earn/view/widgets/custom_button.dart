import 'package:flutter/material.dart';
import '../../color_class.dart';

/// Custom button
class CustomButton extends StatelessWidget {
  final String value;
  final Color color;
  final VoidCallback onTap;

  const CustomButton({super.key, required this.value, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: 200,
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
