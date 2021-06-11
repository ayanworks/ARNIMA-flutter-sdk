/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/
import 'package:hive/hive.dart';

part 'connectiondata.g.dart';

@HiveType(typeId: 1)
class ConnectionData extends HiveObject {
  @HiveField(0)
  final String connectionId;

  @HiveField(1)
  final String connection;

  ConnectionData(this.connectionId, this.connection);
}
