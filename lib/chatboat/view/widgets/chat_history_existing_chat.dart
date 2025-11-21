import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../refer_and_earn/color_class.dart';
import '../../controller/chat_boat_controller.dart';
import '../../model/title_item.dart';

class ChatHistoryExistingChat extends StatelessWidget {
  const ChatHistoryExistingChat({super.key, required this.message});
  final TitleItem message;

  bool get _isLoading => message.replyFromBot["isLoading"] == true;
  bool get _isError => message.replyFromBot["isError"] == true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message.message,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ColorsClass.blackColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: _isLoading
              ? Lottie.asset(
                  "assets/lottie/3-dot.json",
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                )
              : Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: _isError
                        ? Colors.red.withOpacity(0.1)
                        : ColorsClass.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
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

                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              message.replyFromBot["reply"] ?? "",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _isError
                                    ? Colors.red
                                    : ColorsClass.blackColor,
                              ),
                            ),
                          ),
                          if (!_isLoading) const SizedBox(height: 20),
                        ],
                      ),
                      if (!_isLoading && !_isError)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Consumer<ChatBoatProvider>(
                            builder: (context, value, _) {
                              final isLiked = message.replyFromBot["like"];
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      value.feedbackOfReply(
                                        replyId: message.replyFromBot["id"],
                                        like: true,
                                      );
                                    },
                                    child: SvgPicture.asset(
                                      isLiked == true
                                          ? "assets/svg/like-filled.svg"
                                          : "assets/svg/like.svg",
                                      color: isLiked == true
                                          ? Colors.green
                                          : Colors.grey,
                                      height: isLiked == true ? 20 : null,
                                      width: isLiked == true ? 20 : null,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  InkWell(
                                    onTap: () {
                                      value.feedbackOfReply(
                                        replyId: message.replyFromBot["id"],
                                        like: false,
                                      );
                                    },
                                    child: SvgPicture.asset(
                                      isLiked == false
                                          ? "assets/svg/dislike-filled.svg"
                                          : "assets/svg/dislike.svg",
                                      color: isLiked == false
                                          ? Colors.red
                                          : Colors.grey,
                                      height: isLiked == false ? 20 : null,
                                      width: isLiked == false ? 20 : null,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
