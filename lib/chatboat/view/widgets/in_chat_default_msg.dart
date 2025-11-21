import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../refer_and_earn/color_class.dart';
import '../../controller/chat_boat_controller.dart';

class InChatDefaultMsg extends StatelessWidget {
  const InChatDefaultMsg({super.key, this.imgWidth = 400});
  final double imgWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: ColorsClass.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Image.asset(
                    "assets/images/logo_foodchow.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "Foodchow AI Assistant",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ColorsClass.blackColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Hello 😊",
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: ColorsClass.blackColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Are you looking for a powerful marketing system to grow your business?",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: ColorsClass.blackColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "This video explains how FoodChow works and helps you get more clients, profits, and productivity.",
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: ColorsClass.blackColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Get in touch with our team and we'll be happy to help!",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: ColorsClass.blackColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () {
                  Provider.of<ChatBoatProvider>(
                    context,
                    listen: false,
                  ).urlLaunch("https://www.youtube.com/watch?v=cK7gv-gik9s");
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: imgWidth,
                      height: double.infinity,
                      child: Image.network(
                        'https://img.youtube.com/vi/cK7gv-gik9s/sddefault.jpg',
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Text("Could not load thumbnail"),
                          );
                        },
                      ),
                    ),
                    const Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 50,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
