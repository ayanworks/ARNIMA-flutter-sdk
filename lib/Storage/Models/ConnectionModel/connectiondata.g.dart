/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectiondata.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConnectionDataAdapter extends TypeAdapter<ConnectionData> {
  @override
  final int typeId = 1;

  @override
  ConnectionData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConnectionData(
      fields[0] as String,
      fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ConnectionData obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.connectionId)
      ..writeByte(1)
      ..write(obj.connection);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectionDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
