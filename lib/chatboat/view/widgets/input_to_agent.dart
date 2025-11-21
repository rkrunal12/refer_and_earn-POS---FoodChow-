
import 'package:flutter/material.dart';

import '../../../refer_and_earn/color_class.dart';
import '../../controller/chat_boat_controller.dart';

class InputToTheAgent extends StatelessWidget {
  const InputToTheAgent({
    super.key,
    required this.provider,
    required this.firstMsgController,
    required this.onMessageSent,
  });

  final ChatBoatProvider provider;
  final TextEditingController firstMsgController;
  final VoidCallback onMessageSent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: ColorsClass.white,
          borderRadius: const BorderRadius.all(Radius.circular(40)),
          border: Border.all(color: ColorsClass.primary, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: firstMsgController,
                  focusNode: provider.inputFocusNode,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (value) {
                    final text = firstMsgController.text.trim();
                    if (text.isEmpty) return;
                    if (provider.chatIdChatUi == null) {
                      provider.addNewChat(question: text);
                      provider.startNewChat();
                    } else {
                      provider.addMessageToExistingChat(question: text);
                    }
                    firstMsgController.clear();
                    onMessageSent(); 
                  },
                  decoration: const InputDecoration(
                    hintText: "Ask a question...",
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 10,
                    ),
                  ),
                ),
              ),
              InkWell(
                child: const Padding(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Icon(Icons.send, color: ColorsClass.primary),
                ),
                onTap: () {
                  final text = firstMsgController.text.trim();
                  if (text.isEmpty) return;
                  if (provider.chatIdChatUi == null) {
                    provider.addNewChat(question: text);
                  } else {
                    provider.addMessageToExistingChat(question: text);
                  }
                  firstMsgController.clear();
                  onMessageSent(); 
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
