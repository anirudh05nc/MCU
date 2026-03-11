// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'waste_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WasteItemAdapter extends TypeAdapter<WasteItem> {
  @override
  final int typeId = 1;

  @override
  WasteItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WasteItem(
      id: fields[0] as int,
      file: fields[1] as String,
      wasteType: fields[2] as String,
      qty: fields[3] as String,
      dispose: (fields[4] as List).cast<String>(),
      dont: (fields[5] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, WasteItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.file)
      ..writeByte(2)
      ..write(obj.wasteType)
      ..writeByte(3)
      ..write(obj.qty)
      ..writeByte(4)
      ..write(obj.dispose)
      ..writeByte(5)
      ..write(obj.dont);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WasteItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
