import 'package:hive/hive.dart';

part 'title_item.g.dart';

@HiveType(typeId: 3)
class TitleItem {
  @HiveField(0)
  final String message;

  @HiveField(1)
  final Map<String, dynamic> replyFromBot;

  TitleItem({required this.message, required this.replyFromBot});
}
