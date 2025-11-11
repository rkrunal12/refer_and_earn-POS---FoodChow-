import 'package:hive/hive.dart';

import 'title_item.dart';

part 'message_data.g.dart';

@HiveType(typeId: 1)
class MessageData extends HiveObject {
  @HiveField(0)
  List<TitleItem> chatHistory;

  @HiveField(1)
  DateTime time;

  MessageData({required this.chatHistory, required this.time});
}
