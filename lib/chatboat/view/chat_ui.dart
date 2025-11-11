import 'package:flutter/material.dart';
import 'widgets.dart';

class ChatUi extends StatefulWidget {
  const ChatUi({super.key, this.isMobile = false});
  final bool isMobile;

  @override
  State<ChatUi> createState() => _ChatUiState();
}

class _ChatUiState extends State<ChatUi> {
  @override
  Widget build(BuildContext context) {
    return widget.isMobile
        ? ChatUIMain()
        : Positioned(right: 20, bottom: 80, child: ChatUIMain());
  }
}
