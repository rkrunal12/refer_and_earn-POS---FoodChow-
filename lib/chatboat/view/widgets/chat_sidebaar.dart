import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../refer_and_earn/color_class.dart';
import '../../controller/chat_boat_controller.dart';

class ChatSideBar extends StatelessWidget {
  final VoidCallback? onItemTap;

  const ChatSideBar({super.key, this.onItemTap});

  String _getTimeDifference(String timeString) {
    try {
      final chatTime = DateTime.parse(timeString);
      final diff = DateTime.now().difference(chatTime);
      if (diff.inSeconds < 60) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return timeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChatBoatProvider>(context);

    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
            child: Text(
              "Chat History",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: provider.chatItems.isEmpty
                ? Center(
                    child: Text(
                      "Get started with your first query",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    itemCount: provider.chatItems.length,
                    itemBuilder: (context, index) {
                      final item = provider.chatItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        elevation: 1,
                        color: Colors.white,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          onTap: () {
                            provider.setChatPopupPage(item.id);
                            if (onItemTap != null) {
                              onItemTap!();
                            }
                          },
                          leading: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Image.asset(
                              "assets/images/logo_foodchow.png",
                              width: 30,
                              height: 30,
                            ),
                          ),
                          title: Text(
                            item.data.chatHistory.isNotEmpty
                                ? item.data.chatHistory[0].message.length > 25
                                      ? "${item.data.chatHistory[0].message.substring(0, 25)}..."
                                      : item.data.chatHistory[0].message
                                : "New chat",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            _getTimeDifference(item.data.time.toString()),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsClass.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                provider.setChatPopupPage(null);
                if (onItemTap != null) {
                  onItemTap!();
                }
              },
              icon: const Icon(Icons.message_sharp, color: Colors.white),
              label: Text(
                "New Conversation",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
