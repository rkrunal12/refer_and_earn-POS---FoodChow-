import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../refer_and_earn/color_class.dart';
import '../controller/chat_boat_controller.dart';

class ChatboatChat extends StatelessWidget {
  const ChatboatChat({super.key, this.isMobile});
  final bool? isMobile;

  String _getTimeDifference(String timeString) {
    try {
      DateTime chatTime = DateTime.parse(timeString);
      Duration diff = DateTime.now().difference(chatTime);

      if (diff.inSeconds < 60) {
        return 'Just now';
      } else if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}h ago';
      } else {
        return '${diff.inDays}d ago';
      }
    } catch (e) {
      // In case the time string isn’t in DateTime format
      return timeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: isMobile == true ? double.infinity : 250,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 13.0),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Consumer<ChatBoatProvider>(
                builder: (context, provider, _) {
                  return provider.chatItems.isEmpty
                      ? Text("Get start with your first query")
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Chat History",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...provider.chatItems.map(
                              (item) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Card(
                                  color: Colors.white,
                                  child: InkWell(
                                    onTap: () {
                                      Provider.of<ChatBoatProvider>(
                                        context,
                                        listen: false,
                                      ).setChatPopupPage(item.id);
                                    },
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8.0,
                                        ),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          child: Image.asset(
                                            "assets/images/logo_foodchow.png",
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        item.data.chatHistory[0].message,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Text(
                                        _getTimeDifference(
                                          item.data.time.toString(),
                                        ),
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                },
              ),
            ),
            Positioned(
              bottom: 20,
              left: 50,
              right: 50,
              child: FloatingActionButton.small(
                onPressed: () {
                  Provider.of<ChatBoatProvider>(
                    context,
                    listen: false,
                  ).setChatPopupPage(null);
                },
                backgroundColor: ColorsClass.primary,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/chat.png",
                      height: 30,
                      width: 30,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "New Conversation",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
