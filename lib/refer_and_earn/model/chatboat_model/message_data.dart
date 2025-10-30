import 'package:hive/hive.dart';

part 'message_data.g.dart';

@HiveType(typeId: 1)
class MessageData extends HiveObject {
  @HiveField(0)
  List<String> title;

  @HiveField(1)
  DateTime time;

  MessageData({
    required this.title,
    required this.time,
  });
}
