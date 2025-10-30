import 'package:hive/hive.dart';
import 'message_data.dart';

part 'message_model.g.dart';

@HiveType(typeId: 0)
class MessageModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  MessageData data;

  MessageModel({
    required this.id,
    required this.data,
  });
}
