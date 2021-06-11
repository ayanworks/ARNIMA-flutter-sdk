/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/
import 'package:hive/hive.dart';

part 'presentationdata.g.dart';

@HiveType(typeId: 5)
class PresentationData extends HiveObject {
  @HiveField(0)
  final String presentationId;

  @HiveField(1)
  final String connectionId;

  @HiveField(2)
  final String presentation;

  PresentationData(
    this.presentationId,
    this.connectionId,
    this.presentation,
  );
}
