// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logged_in_user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoggedInUserAdapter extends TypeAdapter<LoggedInUser> {
  @override
  final int typeId = 2;

  @override
  LoggedInUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoggedInUser(
      displayName: fields[0] as String?,
      email: fields[1] as String,
      id: fields[2] as String,
      photoUrl: fields[3] as String?,
      accessToken: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LoggedInUser obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.displayName)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.photoUrl)
      ..writeByte(4)
      ..write(obj.accessToken);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoggedInUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
