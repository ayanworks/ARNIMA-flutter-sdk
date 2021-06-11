/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trustpingdata.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrustPingDataAdapter extends TypeAdapter<TrustPingData> {
  @override
  final int typeId = 2;

  @override
  TrustPingData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrustPingData(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TrustPingData obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.connectionId)
      ..writeByte(1)
      ..write(obj.trustPingId)
      ..writeByte(2)
      ..write(obj.trustPingMessage)
      ..writeByte(3)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrustPingDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
