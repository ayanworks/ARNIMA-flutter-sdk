/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/
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
  final String thId;

  @HiveField(4)
  final bool isProcessed;

  @HiveField(5)
  final String connectionId;

  MessageData({
    this.messageId,
    this.messages,
    this.auto,
    this.thId = '0',
    this.isProcessed,
    this.connectionId,
  });
}
