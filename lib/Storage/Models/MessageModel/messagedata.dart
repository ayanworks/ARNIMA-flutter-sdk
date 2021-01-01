import 'package:hive/hive.dart';

part 'messagedata.g.dart';

@HiveType(typeId: 3)
class MessageData extends HiveObject {
  @HiveField(0)
  final String messageId;

  @HiveField(1)
  final String messages;

  @HiveField(2)
  final bool auto;

  @HiveField(3)
  String thId = '0';

  @HiveField(4)
  final bool isProcessed;

  MessageData(this.messageId, this.messages, this.auto, this.isProcessed);
}
