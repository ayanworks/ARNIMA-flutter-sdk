/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presentationdata.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PresentationDataAdapter extends TypeAdapter<PresentationData> {
  @override
  final int typeId = 5;

  @override
  PresentationData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PresentationData(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PresentationData obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.presentationId)
      ..writeByte(1)
      ..write(obj.connectionId)
      ..writeByte(2)
      ..write(obj.presentation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PresentationDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
